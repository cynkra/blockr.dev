# Sidebar — Requirements

## What must be true when we're done

A custom sidebar in blockr.dock that replaces both the current block-adding modal and the Bootstrap offcanvas, serving as a single, multi-purpose panel for board management actions.

## Visual design

The look and feel should match the working prototype deployed at https://blockr.cloud/app/empty (branch `blockr.dock@feat/sidebar-s3-dispatch`). The CSS and overall design language are already validated, the end result should feel like the same product.

## Requirements

### Sidebar container

- A slide-in panel that can show and hide without page reload
- Content swaps dynamically based on what triggered the sidebar (adding a block, editing a stack, opening settings, etc.)
- Must replace the current Bootstrap offcanvas — no more Bootstrap offcanvas anywhere in blockr.dock
- Custom CSS consistent with the rest of the blockr.dock design system

### Block browsing

- Blocks displayed as cards showing: name, description, icon, package badge
- Cards grouped by category (Input, Transform, Plot, Output, etc.)
- Search input that filters across block name, description, category, and package
- Quick-add: single click on a card adds the block immediately
- Detailed-add: expanding a card's accordion reveals fields for custom name, ID, and input selection

### Content types

All content types from the prototype are in scope:

- **add_block** — add a standalone block to the board
- **append_block** — add a block downstream of a source block, auto-linked
- **prepend_block** — add a block upstream of a target block, auto-linked
- **add_link** — create a link between existing blocks
- **create_stack** / **edit_stack** — group blocks into stacks
- **add_panel** — manage dock panels
- **settings** — board-level settings (replacing the Bootstrap offcanvas)

### Extensibility

- Extension packages can define new sidebar content types without modifying blockr.dock
- The mechanism for this should use S3 dispatch (as in the prototype) or an equivalent pattern that allows the same level of extensibility

### Keyboard navigation

- Arrow keys to move between cards
- Enter to select/confirm
- Escape to close the sidebar

### Pinning

Not required, but a nice-to-have: the sidebar can stay open across actions, so users can add multiple blocks without repeatedly opening it. If included, the board layout should adjust (not just overlay).

## Non-goals

- **Sidebar ↔ dock panel promotion** — the idea of converting a pinned sidebar into a draggable dock panel is worth exploring later, but out of scope for this iteration
- **Drag-and-drop from sidebar to canvas** — not required
- **Changes to blockr.core** — the sidebar lives in blockr.dock; blockr.core's `manage_blocks` plugin is unaffected
