---
description: Build MkDocs documentation site locally
---

Build and preview the architecture docs locally:

```bash
cd /home/mmber/banxe-architecture
pip install mkdocs-material pymdown-extensions
mkdocs serve
```

Then open: http://127.0.0.1:8000

To build static site:
```bash
mkdocs build --strict
```

Output goes to `site/` directory.
