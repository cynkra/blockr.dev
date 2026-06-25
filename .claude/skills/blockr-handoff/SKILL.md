---
name: blockr-handoff
description: |
  File-based handover between Claude sessions (local <-> dev container, or parallel
  sessions). Trigger on "prepare handover" (write the current state to
  _scratch/handover/HANDOVER.md) or "pick handover" / "continue from handover"
  (read it and resume the work).
argument-hint: "[prepare | pick] [focus hint]"
---

# Handover

A handover is a single file — `_scratch/handover/HANDOVER.md` — that one session
writes and another reads. It works across the dev-container boundary because the
workspace is bind-mounted: the **same file** is at
`/Users/christophsax/git/blockr/_scratch/handover/HANDOVER.md` (host) and
`/workspace/_scratch/handover/HANDOVER.md` (container). No clipboard, no copy/paste.

## Locate the handover directory

Always resolve the path first (works in or out of the container):

```sh
if [ -d /workspace/_scratch ]; then ROOT=/workspace; else ROOT=/Users/christophsax/git/blockr; fi
HO="$ROOT/_scratch/handover"
```

## Mode: "prepare handover"

Write the current state so a fresh session can take over.

1. **Gather context silently** (don't narrate each step):
   - Git state — for each relevant repo: `git branch --show-current`, `git log --oneline -5`, `git diff --stat`. In the dev container use `/usr/lib/git-core/git -C <repo> ...`; on the host use plain `git -C <repo> ...`.
   - Key files touched or discussed this session, and why each matters.
   - What was done, and the concrete next steps. Fold in any focus hint: $ARGUMENTS.

2. **Archive the previous handover** so nothing is lost:
   ```sh
   if [ -f "$HO/HANDOVER.md" ]; then
     TS=$(date +%Y%m%d-%H%M%S); mkdir -p "$HO/archive/$TS"
     mv "$HO/HANDOVER.md" "$HO/archive/$TS/"
     # move companion files too if this handover had any (e.g. issues/ patches/)
   fi
   mkdir -p "$HO"
   ```

3. **Write `$HO/HANDOVER.md`** — self-contained, scannable in ~30s, paths not file dumps:

   ```markdown
   # Handover — <one-line title>

   **For:** <who picks this up — e.g. "an agent OUTSIDE the dev container with gh + push auth">

   ## Context
   <1-2 sentences: which package(s), what area.>

   ## State
   - Branch `<branch>` in `<repo-dir>` — uncommitted: <summary or none>
   - Recent commits: <last 2-3 relevant>

   ## What was done
   - <3-5 bullets>

   ## Key files
   - `path/to/file.R` — <why it matters>

   ## What to do next
   - <clear, actionable steps with file paths + function names>

   ## Notes / gotchas
   - <constraints the next session needs — auth, ports, env, verification commands>
   ```

   If the handover needs attachments (patches, issue specs, scripts), drop them in
   the same folder and reference them by relative path from `HANDOVER.md`. Keep the
   default case to a single file.

4. **Confirm**: print the absolute path and a 3-line summary (task / branch / next step).

## Mode: "pick handover" / "continue from handover"

1. Read `$HO/HANDOVER.md`. If it's missing, say so and list `$HO/archive/`.
2. Verify the state it describes still holds — branches exist, commits present,
   files at the listed paths. Flag anything that drifted.
3. Orient to the "What to do next" section and start, surfacing any blockers
   (missing auth, env vars, ports) before making changes.
