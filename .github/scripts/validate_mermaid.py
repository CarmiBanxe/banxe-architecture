import sys, re, subprocess, tempfile, os

md_file = sys.argv[1]
content = open(md_file).read()
blocks = re.findall(r'```mermaid\n(.*?)\n```', content, re.DOTALL)

for i, block in enumerate(blocks):
    with tempfile.NamedTemporaryFile(suffix='.mmd', mode='w', delete=False) as f:
        f.write(block)
        fname = f.name
    result = subprocess.run(
        ['mmdc', '-i', fname, '-o', '/tmp/test-out.svg', '--quiet'],
        capture_output=True, text=True
    )
    os.unlink(fname)
    if result.returncode != 0:
        print(f"Invalid Mermaid in {md_file} (block {i+1}): {result.stderr[:200]}")
        sys.exit(1)
    else:
        print(f"Block {i+1} in {md_file} OK")
