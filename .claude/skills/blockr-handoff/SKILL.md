---
name: blockr-handoff
description: |
  Generate a continuation prompt for another Claude Code instance and copy to clipboard.
argument-hint: "[focus hint]"
---

# Handoff

Generate a prompt that another Claude Code instance can use to continue the current work. This is used when switching between local and container environments or handing off to a parallel session.

## Step 1: Gather context (silently)

Collect — don't print each step to the user:

1. **Git state**: Run `git branch --show-current`, `git log --oneline -5`, and `git diff --stat` in the current working directory. If not in a git repo, check subdirectories for repos and gather state from each relevant one.
2. **Key files**: Identify files most relevant to the current conversation — files that were read, edited, or discussed.
3. **Current task**: Summarize what was being worked on based on conversation history.
4. **Next steps**: What remains to be done. If the user provided a focus hint, incorporate it: $ARGUMENTS

## Step 2: Generate prompt

Write a self-contained prompt using this template:

```
## Context

[1-2 sentences: what project, what area of the codebase]

## Current state

- Branch: `branch-name` in `package-dir`
- Uncommitted changes: [summary or "none"]
- Recent commits: [last 2-3 relevant ones]

## What was done

[3-5 bullet points of what was accomplished or attempted]

## Key files

- `path/to/file.R` — [why it matters]
- ...

## What to do next

[Clear, actionable steps with specific file paths and function names]

## Important notes

[Gotchas, constraints, or things the next instance needs to know]
```

Keep it concise — the prompt should be scannable in 30 seconds. Don't include full file contents, just paths and descriptions.

## Step 3: Copy and confirm

1. Try to copy the prompt to clipboard using the first available tool:
   - `pbcopy` (macOS)
   - `xclip -selection clipboard` (Linux with X11)
   - `xsel --clipboard --input` (Linux alternative)
   - `wl-copy` (Wayland)
2. If clipboard copy succeeded, tell the user it's copied and show a 3-line summary (task, branch, next step).
3. If **no clipboard tool is available**, print the full prompt text to the console so the user can select and copy it manually. Add a short note above it: "No clipboard available — copy the prompt below."
