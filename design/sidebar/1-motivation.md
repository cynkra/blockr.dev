# Sidebar — Motivation

## The core need

blockr.dock needs a **multi-purpose panel** — a shared UI surface that can host different kinds of content depending on context. Block browsing is the first and most important use case, but the same surface should serve settings, code preview, and future features like an AI assistant.

Today we have three UI surfaces, none of which fully fits:

1. **Modal** — blockr.core's `manage_blocks` plugin uses a modal with a `selectInput()` dropdown for adding blocks. Minimal, but functional.
2. **Bootstrap offcanvas** — blockr.dock uses this for settings. Visually inconsistent with the rest of the app and limited in capability.
3. **Dock panels** — the extensible workhorse of blockr.dock. Dock panels host block UI, and extension packages can add custom panels (e.g., blockr.md puts a markdown/PPTX editor in one). These are powerful and proven.

Dock panels could theoretically host a block browser, but they're designed as **persistent workspace content** — part of the layout, always visible when open. A block browser is typically **transient navigation** — you want it when you're adding blocks and gone when you're not. That said, the boundary doesn't have to be rigid: a pinned sidebar could promote itself into a dock panel (draggable, rearrangeable), and a dock panel could collapse back into a sidebar. Keeping this flexible is worth exploring in the design phase.

## Why not just improve the existing surfaces?

Most problems with the current modal — flat list, no metadata, no categorization — could be fixed within a modal. And dock panels are already extensible. So why build a new thing?

The reasons are structural, not cosmetic:

### 1. Context preservation

A modal covers the board. When users are building a workflow and thinking "what should connect to what I already have?", they lose visual context. A sidebar sits alongside the board — users see both at once.

This is the strongest functional argument. It's not about aesthetics; it's about cognitive load during the primary interaction of a workflow builder.

### 2. Continuous interaction

Adding blocks is repetitive — users often add several in a row when building a workflow. A modal requires open → pick → close → open → pick → close. A sidebar can stay open, supporting a continuous building flow without repeated interruption.

### 3. One surface, many purposes

We need UI for: adding blocks, appending/prepending blocks with auto-linking, creating stacks, managing links, settings, panel management — and eventually code preview and an AI assistant. Building a separate modal for each of these is possible but produces a disjointed experience. A single sidebar that swaps content based on context is more economical and more consistent.

### 4. The Bootstrap offcanvas is already failing

blockr.dock uses a Bootstrap offcanvas for settings today. It's visually inconsistent with the rest of the app and limited in what it can do. We need a custom sidebar anyway — the question is whether to build one that only serves settings, or one that serves everything.

## What the industry does

Node-based editors and workflow builders commonly use sidebars for adding components:

- **[n8n](https://docs.n8n.io/courses/level-one/chapter-1/)** uses a right sidebar panel with categories, search, and click-to-add
- **[React Flow](https://reactflow.dev/ui/templates/workflow-editor)** templates use drag-from-sidebar
- **OpenAI's workflow builder** uses a sidebar for component selection

This isn't universal — Parabola (a no-code workflow builder) deliberately chose modals over sidebars, arguing that sidebars give limited space and competing visual attention, while modals force focus on a single task. Blender uses a context menu (`Shift+A`), not a sidebar.

The sidebar pattern works best when the primary interaction is **browsing and adding** (our case) rather than **complex configuration** (where modals' focused attention is an advantage). Since block configuration in blockr happens inside the block itself after addition, the sidebar only needs to handle discovery and selection — a good fit.

## Evidence it works

A working implementation exists on `blockr.dock@feat/sidebar-s3-dispatch` and is deployed at https://blockr.cloud/app/empty. User feedback has been strongly positive.

Screenshots from the deployed version:

![Sidebar open](screenshots/screenshot-02-sidebar-open.png)

## Why a spec, not just a merge

The prototype works and is testable, but the architecture needs review before merging. The goal of this spec is to define the right design so that Nicolas can do a clean implementation, rather than merging the prototype as-is.

Reference implementation: [`blockr.dock@feat/sidebar-s3-dispatch`](https://github.com/blockr-org/blockr.dock/tree/feat/sidebar-s3-dispatch)
