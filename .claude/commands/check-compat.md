---
name: check-compat
description: Verify backward compatibility of .eflq session files
allowed-tools:
  - Bash
  - Read
  - Grep
---

Verify backward compatibility of `.eflq` session files.
Run `python -m pytest test/` and check that `backend/efio.py` sessionSave still works
with existing session format.
