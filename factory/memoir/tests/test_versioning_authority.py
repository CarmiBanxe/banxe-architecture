"""T06, T10–T15: versioning, replay, XOR, perimeter, no-authority, append-only."""

from __future__ import annotations

import hashlib
import subprocess
from dataclasses import replace
from datetime import timedelta

import pytest

from factory.memoir import registry
from factory.memoir.errors import PerimeterViolation, XorViolation
from factory.memoir.redaction import RegexEntropyRedactor
from factory.memoir.retention import RetentionPolicy
from factory.memoir.store import GitMemoryStore, assert_isolated


def test_T06_history_has_no_raw(store):
    entry = store.store("k", "token ghp_1234567890abcdefghij1234567890abcd tail")
    # recall / checkout / blame must return redacted content only
    assert "ghp_1234567890abcdefghij1234567890abcd" not in (store.recall(entry) or "")
    head = store.blame(entry)[0].split()[0]
    assert "ghp_1234567890abcdefghij1234567890abcd" not in (store.checkout(entry, head) or "")


def test_T10_replay_returns_data_not_action(store):
    entry = store.store("note", "just a normal note")
    got = store.recall(entry)
    assert isinstance(got, str) and "normal note" in got  # data, not execution


def test_T11_replay_no_exec(store, tmp_path):
    marker = tmp_path / "flag"
    payload = "danger: os.system would touch a file; but this is inert text"
    entry = store.store("k", payload)
    out = store.recall(entry)
    assert isinstance(out, str) and "os.system" in out  # inert data, not executed
    assert not marker.exists()  # replay never runs stored content


def test_T12_xor_second_engine_refused():
    registry.reset()
    registry.register_engine("memoir")
    with pytest.raises(XorViolation):
        registry.register_engine("agentmemory")


def test_T12_xor_store_construction(tmp_path, policy):
    GitMemoryStore(tmp_path / "a.git", policy, redactor=RegexEntropyRedactor())
    other = replace(policy, engine="agentmemory")
    with pytest.raises(XorViolation):
        GitMemoryStore(tmp_path / "b.git", other, redactor=RegexEntropyRedactor())


def test_T13_factory_only_project_fork_disabled(tmp_path):
    proj = RetentionPolicy(engine="memoir", fork="project",
                           max_age=timedelta(days=1), max_entries=10,
                           hard_cap_bytes=1000, purge_schedule="x")
    with pytest.raises(PerimeterViolation):
        GitMemoryStore(tmp_path / "p.git", proj)


def test_T13_isolation_refuses_repo_inside_code_root(tmp_path):
    code = tmp_path / "code"
    (code / "sub").mkdir(parents=True)
    with pytest.raises(PerimeterViolation):
        assert_isolated(code / "sub" / "mem.git", code)


def test_T14_no_authority_mutation(tmp_path, policy):
    # a fake code repo + ledger; memoir ops must leave them byte-identical
    code = tmp_path / "code"
    code.mkdir()
    subprocess.run(["git", "init", "-q", str(code)], check=True)
    ledger = code / "IL-SEQUENCE.json"
    ledger.write_text('{"x": 1}', encoding="utf-8")
    subprocess.run(["git", "-C", str(code), "add", "-A"], check=True)
    subprocess.run(["git", "-C", str(code), "-c", "user.email=t@t", "-c",
                    "user.name=t", "commit", "-qm", "init"], check=True)
    before = hashlib.sha256(ledger.read_bytes()).hexdigest()

    st = GitMemoryStore(tmp_path / "mem.git", policy, code_root=code)
    e = st.store("k", "content")
    st.branch_from("wip")
    st.rollback(e, st.blame(e)[0].split()[0])
    st.assert_no_authority()  # no ledger/network references in source

    after = hashlib.sha256(ledger.read_bytes()).hexdigest()
    status = subprocess.run(["git", "-C", str(code), "status", "--porcelain"],
                            capture_output=True, text=True).stdout
    assert before == after  # ledger untouched
    assert status == ""     # code repo clean — no mutation


def test_T15_append_only_rollback_is_new_commit(store):
    entry = store.store("k", "v1")

    def count() -> int:
        out = subprocess.run(
            ["git", f"--git-dir={store.dir}", "rev-list", "--count",
             "refs/heads/main"], capture_output=True, text=True, check=True)
        return int(out.stdout.strip())

    n0 = count()
    head = store.blame(entry)[0].split()[0]
    store.rollback(entry, head)
    assert count() == n0 + 1  # rollback ADDED a commit; history never rewritten


def test_source_imports_no_authority_or_network(tmp_path, policy):
    # AST-level: no memoir module imports ledger/build_ledger/network libs
    st = GitMemoryStore(tmp_path / "clean.git", policy)
    st.assert_no_authority()  # raises AuthorityViolation if any banned import exists
