"""Git-plumbing memory store over an ISOLATED bare repo (ADR-165 §2/§5/§8/§9).

Native branch/commit/blame/checkout/rollback via git plumbing (hash-object /
write-tree / commit-tree / update-ref) with a temp index — no working tree, no
checkout of a code repo. REDACT → THEN commit: raw values are never written, so
history/blame/checkout/rollback can only return redacted content.

Authority (PRECOND-07): every op targets GIT_DIR = the memory-repo ONLY. The store
imports no ledger/build_ledger and writes nothing outside its repo dir.
Perimeter (PRECOND-05): factory fork only; project fork disabled by default.
"""

from __future__ import annotations

import ast
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

from .errors import AuthorityViolation, MemoirError, PerimeterViolation
from .redaction import PiiRedactorPort, RegexEntropyRedactor, redact_or_refuse
from .registry import register_engine
from .retention import RetentionPolicy

_SAFE = re.compile(r"[^A-Za-z0-9._-]+")
_ENV = {
    "GIT_AUTHOR_NAME": "memoir", "GIT_AUTHOR_EMAIL": "memoir@factory.local",
    "GIT_COMMITTER_NAME": "memoir", "GIT_COMMITTER_EMAIL": "memoir@factory.local",
    "GIT_CONFIG_GLOBAL": os.devnull, "GIT_CONFIG_SYSTEM": os.devnull,
}


def assert_isolated(repo_dir: Path, code_root: Path | None) -> None:
    """Refuse a memory-repo path that lives inside a code checkout (ADR-165 §2)."""
    if code_root is None:
        return
    rd, cr = repo_dir.resolve(), code_root.resolve()
    if rd == cr or cr in rd.parents:
        raise PerimeterViolation(f"memory-repo {rd} must not live inside code root {cr}")


class GitMemoryStore:
    def __init__(self, repo_dir: str | Path, policy: RetentionPolicy, *,
                 redactor: PiiRedactorPort | None = None, fork: str = "factory",
                 code_root: str | Path | None = None, branch: str = "main") -> None:
        if fork != "factory" or policy.fork != "factory":
            raise PerimeterViolation("factory fork only; project fork disabled by default")
        self.dir = Path(repo_dir)
        assert_isolated(self.dir, Path(code_root) if code_root else None)
        register_engine(policy.engine)  # XOR (PRECOND-04)
        self.policy = policy
        self.redactor = redactor or RegexEntropyRedactor()
        self.branch = branch
        self._init_repo()

    # ── git plumbing ──
    def _git(self, *args: str, stdin: str | None = None, index: Path | None = None,
             work_tree: Path | None = None) -> str:
        env = {**os.environ, **_ENV, "GIT_DIR": str(self.dir)}
        if index is not None:
            env["GIT_INDEX_FILE"] = str(index)
        if work_tree is not None:
            env["GIT_WORK_TREE"] = str(work_tree)
        r = subprocess.run(["git", *args], env=env, input=stdin, text=True,
                           capture_output=True)
        if r.returncode != 0:
            raise MemoirError(f"git {args[0]} failed: {r.stderr.strip()}")
        return r.stdout

    def _init_repo(self) -> None:
        if not (self.dir / "HEAD").exists():
            self.dir.mkdir(parents=True, exist_ok=True)
            subprocess.run(["git", "init", "--bare", "-q", str(self.dir)],
                           check=True, capture_output=True)

    def _ref(self, branch: str | None = None) -> str:
        return f"refs/heads/{branch or self.branch}"

    def _exists(self, branch: str | None = None) -> bool:
        return subprocess.run(
            ["git", f"--git-dir={self.dir}", "show-ref", "--verify", "--quiet",
             self._ref(branch)]).returncode == 0

    def _commit(self, adds: dict[str, str], removes: list[str], msg: str,
                branch: str | None = None) -> str:
        ref = self._ref(branch)
        tmpdir = Path(tempfile.mkdtemp(prefix="memoir-idx-"))
        idx = tmpdir / "index"  # must NOT pre-exist (empty file = invalid index)
        try:
            if self._exists(branch):
                self._git("read-tree", ref, index=idx, work_tree=tmpdir)
            for path, content in adds.items():
                blob = self._git("hash-object", "-w", "--stdin", stdin=content).strip()
                self._git("update-index", "--add", "--cacheinfo",
                          f"100644,{blob},{path}", index=idx, work_tree=tmpdir)
            for path in removes:
                self._git("update-index", "--force-remove", path, index=idx,
                          work_tree=tmpdir)
            tree = self._git("write-tree", index=idx, work_tree=tmpdir).strip()
            parent = [self._git("rev-parse", ref).strip()] if self._exists(branch) else []
            pargs = [x for p in parent for x in ("-p", p)]
            commit = self._git("commit-tree", tree, *pargs, "-m", msg).strip()
            self._git("update-ref", ref, commit)
            return commit
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)

    # ── public API (memory content only) ──
    def store(self, key: str, content: str) -> str:
        """Redact key + content, then commit. Raises (persists nothing) on any
        redaction uncertainty / RED-zone / oversize."""
        red_key = redact_or_refuse(self.redactor, key)
        red_content = redact_or_refuse(self.redactor, content)
        if len(red_content.encode()) > self.policy.hard_cap_bytes:
            raise MemoirError("entry exceeds hard_cap_bytes (refused)")
        seq = int(self._git("rev-list", "--count", self._ref()).strip()) if self._exists() else 0
        entry = f"entries/{seq:08d}-{_SAFE.sub('_', red_key)[:80]}"
        self._commit({entry: red_content}, [], f"store {entry}")
        self._evict()
        return entry

    def recall(self, entry: str, ref: str | None = None) -> str | None:
        """Return stored (already-redacted) content as DATA. Never executes it."""
        try:
            return self._git("cat-file", "-p", f"{ref or self._ref()}:{entry}")
        except MemoirError:
            return None

    def checkout(self, entry: str, ref: str) -> str | None:
        return self.recall(entry, ref)

    def list_entries(self, branch: str | None = None) -> list[tuple[str, int]]:
        if not self._exists(branch):
            return []
        out = self._git("ls-tree", "-l", self._ref(branch), "entries/")
        rows: list[tuple[str, int]] = []
        for ln in out.splitlines():
            parts = ln.split(maxsplit=4)
            if len(parts) == 5 and parts[1] == "blob":
                rows.append((parts[4], int(parts[3])))
        return sorted(rows)

    def count(self, branch: str | None = None) -> int:
        return len(self.list_entries(branch))

    def live_bytes(self, branch: str | None = None) -> int:
        return sum(sz for _, sz in self.list_entries(branch))

    def blame(self, entry: str, branch: str | None = None) -> list[str]:
        """History of an entry (redacted content only). Audit, not raw."""
        out = self._git("log", "--format=%H %aI %s", self._ref(branch), "--", entry)
        return [ln for ln in out.splitlines() if ln.strip()]

    def branch_from(self, name: str, source: str | None = None) -> None:
        self._git("branch", name, self._ref(source))

    def rollback(self, entry: str, to_ref: str, branch: str | None = None) -> str:
        """Restore an entry's earlier (already-redacted) content as a NEW commit.
        NEVER rewrites history / resets (append-only, ADR-059)."""
        prior = self.checkout(entry, to_ref)
        if prior is None:
            raise MemoirError(f"cannot rollback: {entry} absent at {to_ref}")
        return self._commit({entry: prior}, [], f"rollback {entry} to {to_ref}", branch)

    def _evict(self, branch: str | None = None) -> None:
        """On-write eviction: bound the LIVE set to max_entries + hard_cap_bytes,
        oldest-first, via a NEW removal commit (append-only history)."""
        entries = self.list_entries(branch)
        removes: list[str] = []
        idx = 0
        over = len(entries) - self.policy.max_entries
        while idx < len(entries) and over > 0:
            removes.append(entries[idx][0])
            idx += 1
            over -= 1
        total = sum(sz for _, sz in entries[idx:])
        while idx < len(entries) and total > self.policy.hard_cap_bytes:
            removes.append(entries[idx][0])
            total -= entries[idx][1]
            idx += 1
        if removes:
            self._commit({}, removes, f"purge {len(removes)} entry(ies)", branch)

    def purge(self, branch: str | None = None) -> None:
        """Explicit sweep (systemd-timer / CI job) — same bounds as on-write."""
        self._evict(branch)

    def assert_no_authority(self) -> None:
        """Static self-check (AST imports, not string-scan): memoir imports no
        ledger/authority or network machinery (PRECOND-07)."""
        banned = {"ledger", "build_ledger", "requests", "socket", "http",
                  "urllib", "ftplib"}
        import factory.memoir as pkg
        for f in Path(pkg.__file__).parent.glob("*.py"):
            for node in ast.walk(ast.parse(f.read_text(encoding="utf-8"))):
                mods: list[str] = []
                if isinstance(node, ast.Import):
                    mods = [a.name.split(".")[0] for a in node.names]
                elif isinstance(node, ast.ImportFrom) and node.module:
                    mods = [node.module.split(".")[0]]
                bad = set(mods) & banned
                if bad:
                    raise AuthorityViolation(f"{f.name} imports banned {bad}")
