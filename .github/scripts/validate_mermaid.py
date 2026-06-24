import sys, re, subprocess, tempfile, os, json

md_file = sys.argv[1]
content = open(md_file).read()
blocks = re.findall(r'```mermaid\n(.*?)\n```', content, re.DOTALL)

# Puppeteer config to run headless Chromium without sandbox (required in CI)
pcfg = tempfile.NamedTemporaryFile(suffix='.json', mode='w', delete=False)
json.dump({"args": ["--no-sandbox", "--disable-setuid-sandbox"]}, pcfg)
pcfg.close()

failed = False
for i, block in enumerate(blocks):
    with tempfile.NamedTemporaryFile(suffix='.mmd', mode='w', delete=False) as f:
        f.write(block)
        fname = f.name
    result = subprocess.run(
        ['mmdc', '-p', pcfg.name, '-i', fname, '-o', '/tmp/test-out.svg', '--quiet'],
        capture_output=True, text=True
    )
    os.unlink(fname)
    if result.returncode != 0:
        print(f"Invalid Mermaid in {md_file} (block {i+1}): {result.stderr[:200]}")
        failed = True
    else:
        print(f"Block {i+1} in {md_file} OK")

os.unlink(pcfg.name)
sys.exit(1 if failed else 0)
