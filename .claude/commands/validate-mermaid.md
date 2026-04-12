---
description: Validate all Mermaid diagrams in architecture docs
---

```bash
cd /home/mmber/banxe-architecture
npm install -g @mermaid-js/mermaid-cli

find . -name "*.md" -not -path './.git/*' | while read f; do
  # Extract and validate mermaid blocks
  python3 -c "
import re, subprocess, tempfile, os
content = open('$f').read()
blocks = re.findall(r'\`\`\`mermaid\n(.*?)\n\`\`\`', content, re.DOTALL)
for i, block in enumerate(blocks):
    with tempfile.NamedTemporaryFile(suffix='.mmd', mode='w', delete=False) as tf:
        tf.write(block); fname = tf.name
    r = subprocess.run(['mmdc', '-i', fname, '-o', '/tmp/t.svg', '--quiet'], capture_output=True)
    os.unlink(fname)
    print(('✅' if r.returncode == 0 else '❌') + f' Block {i+1} in $f')
"
done
```
