---
name: blockr-screenshot
description: |
  Read screenshots from ./_screenshots/, display them, then archive.
  Use when the user says "look at my screenshot(s)", "see this", or similar.
argument-hint: "<optional context about what to look for>"
---

# blockr-screenshot

Read macOS screenshots dropped into the shared `./_screenshots/` directory.

## Workflow

1. **List** PNG files using Bash (filenames contain spaces, so Glob won't match):
   ```bash
   ls /workspace/_screenshots/*.png 2>/dev/null
   ```
   Exclude anything in `_archive/`.
2. **Read** each `.png` file using the Read tool (it supports images natively). Use the full absolute path from the `ls` output.
3. **Move** every processed image to `_archive/`, creating the directory if needed:
   ```bash
   mkdir -p /workspace/_screenshots/_archive
   mv /workspace/_screenshots/*.png /workspace/_screenshots/_archive/ 2>/dev/null
   ```
4. **Respond** with observations about the screenshot(s), guided by any user context

## Notes

- The user takes screenshots on macOS with Cmd+Shift+3/4/5; they land in `./_screenshots/` via a host mount.
- Always process ALL images in the directory, not just one.
- Archived screenshots remain available in `./_screenshots/_archive/` if needed later.
