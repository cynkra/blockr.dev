---
name: blockr-playwright
description: |
  End-to-end workflow for debugging blockr Shiny apps with the Playwright MCP.
  Covers writing the app, launching it, connecting Playwright, iterating with
  screenshots and console logs, and cleaning up.
argument-hint: "<task description>"
---

# blockr-playwright

Debug blockr Shiny apps interactively using the Playwright MCP server.

## Workflow

### Step 0 — Add Debug Logging First

Before doing anything else, add R-side debug logging to the code you are
investigating. Insert `debug_log()` calls (see **R-side debug logging** below)
at key decision points — function entry, branch conditions, loaded data. This
is not optional: you need logs to see what the server is doing.

Always clear the log at the start of a session:

```r
file.remove("/tmp/blockr-debug.log")
```

Then read it after each interaction via the Read tool.

### Step 1 — Write the App

Two templates are available in `templates/`:

| Template | Use when |
|----------|----------|
| `app-dock.R` | Full dock board with session management, DAG, all packages. Empty board — user adds blocks via UI. |
| `app-demo.R` | Quick demo with a dataset block pre-loaded. Minimal deps. Good for exploring the UI. |

Copy the appropriate template to a working directory and modify for your task.
If the app already exists, skip to Step 2 — but still add debug logging
(Step 0) to the relevant source files.

Key settings (already in both templates):

```r
options(shiny.port = 7860, shiny.launch.browser = FALSE)
```

The fixed port means the URL is always `http://localhost:7860` — no output
parsing required.

### Step 2 — Start the App

First, ensure port 7860 is free (see **Killing the App** below). Then:

```bash
cd /path/to/app && Rscript app.R > /tmp/blockr-app.log 2>&1 &
```

Wait and verify:

```bash
sleep 5 && curl -so /dev/null -w "%{http_code}" http://localhost:7860
```

Should return `200`. If not, check the log:

```
Read /tmp/blockr-app.log
```

### Step 3 — Connect with Playwright

Use the Playwright MCP tools:

1. `browser_navigate` to `http://localhost:7860`
2. `browser_wait_for` — wait 3-5 seconds for Shiny + dock to initialise
3. `browser_take_screenshot` — confirm the app rendered

See `ui-navigation.md` for how to interact with dock board elements.

### Step 4 — Debug Loop

Repeat as needed:

1. **Screenshot** — `browser_take_screenshot` to see current state
2. **Snapshot** — `browser_snapshot` to get element refs for clicking
3. **Interact** — `browser_click`, `browser_type`, `browser_drag` to drive the UI
4. **Read logs** — `browser_console_messages` for JS errors; Read `/tmp/blockr-debug.log` for R-side logs
5. **Modify code** — edit the app, kill the process, restart (Step 2)

### Step 5 — Killing the App

**IMPORTANT:** This container does NOT have `lsof`, `fuser`, `ss`, or
`netstat`. Use this pattern to find and kill the R process:

```bash
# Find the PID
ps -eo pid,cmd | grep "R.*--file=app.R" | grep -v grep

# Kill it (replace PID)
kill -9 <PID>

# Verify port is free
sleep 1 && curl -so /dev/null -w "%{http_code}" http://localhost:7860
# Should return 000 (connection refused) = port is free
```

Or as a one-liner:

```bash
kill -9 $(ps -eo pid,cmd | grep "R.*--file=app.R" | grep -v grep | awk '{print $1}') 2>/dev/null; sleep 1
```

---

## R-side Debug Logging

Use the `debug_log()` helper to write timestamped entries to a known file that
Claude can read at any time via the Read tool.

```r
source("debug-helpers.R")  # or paste inline

debug_log("BOARD", "Board initialised, blocks:", length(blocks))
debug_log("LINK",  "New link from", src, "to", tgt)
```

Logs go to `/tmp/blockr-debug.log`. Read them:

```
Read /tmp/blockr-debug.log
```

See `templates/debug-helpers.R` for the full snippet and usage examples.

## JS-side Debugging

Use Playwright MCP's `browser_console_messages` tool to retrieve recent JS
console output directly — no extra plumbing needed.

## Playwright MCP Tool Reference

| Tool                      | Purpose                                  |
|---------------------------|------------------------------------------|
| `browser_navigate`        | Go to a URL                              |
| `browser_take_screenshot` | Capture the current viewport as image    |
| `browser_snapshot`        | Get accessibility tree with element refs |
| `browser_click`           | Click an element by ref                  |
| `browser_type`            | Type text into a focused element         |
| `browser_console_messages`| Retrieve recent JS console output        |
| `browser_drag`            | Drag from one element to another         |
| `browser_wait_for`        | Wait for text/time                       |
| `browser_fill_form`       | Fill multiple form fields at once        |
| `browser_select_option`   | Select dropdown option                   |

All tools are prefixed with `mcp__playwright__` when called via the MCP
integration (e.g. `mcp__playwright__browser_take_screenshot`).

## Tips

- **Dock panels take time to render.** After `browser_navigate`, wait 3-5
  seconds before the first screenshot. If panels are missing, wait longer or
  use `browser_wait_for` with visible panel content.
- **Always snapshot before clicking.** Use `browser_snapshot` to get element
  refs, then `browser_click` with the ref. Don't guess at selectors.
- **DAG tab** is an extension panel. It may not be visible until you click its
  tab. Use `browser_click` on the DAG tab header if needed.
- **Loading delays** — blocks that fetch data (e.g. dataset blocks) trigger
  async server work. Screenshot after a short delay or wait for expected output
  text.
- **Port conflicts** — if 7860 is already in use, kill the old process first
  (see **Killing the App** above).
- **Multiple sessions** — each Rscript runs one Shiny session. Stop the old one
  before starting a new one on the same port.
- **Missing packages** — if a template fails to load, install the missing
  package. Use Posit repo for CRAN deps, local source for blockr packages:
  ```r
  install.packages("missing_pkg", repos = "https://packagemanager.posit.co/cran/latest")
  install.packages("/workspace/blockr.foo", repos = NULL, type = "source")
  ```
