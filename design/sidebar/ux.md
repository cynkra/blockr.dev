# Sidebar -- UX

## Interaction Flow

1. User clicks a board action button (e.g., "Add Block" in toolbar)
2. Sidebar slides in from the left edge (~380px wide)
3. Sidebar header shows the action name and a close button
4. Content area displays the appropriate UI for that action
5. User completes the action (e.g., selects a block) or presses Escape / clicks close
6. Sidebar slides out; dock returns to full width

If the sidebar is already open and the user clicks a different action, the content
swaps in place without closing and reopening.

## Content Layout (Add Block example)

- **Search input** at top, auto-focused on open, 150ms debounce
- **Card-based selection** below search:
  - Each card shows: icon, block name, description, package badge
  - Cards grouped by category (Input, Transform, Plot, ...)
  - Category headers are collapsible
- **Accordion** at bottom for optional fields:
  - Custom block name
  - Custom block ID
  - Input selection (which block to connect to)
- **Sticky footer** with action buttons (e.g., "Add", "Cancel")

## Keyboard Navigation

- **Arrow Up / Down** -- move between cards
- **Enter** -- select the highlighted card
- **Escape** -- close sidebar
- **Tab** -- move between search, cards, accordion, footer

## Visual States

### Sidebar closed
Standard dock view, full width.

### Sidebar open
Dock panels shift right (or shrink) by ~380px. Sidebar is flush with the left edge.
No overlay or dimming.

`[TODO: screenshot from prototype -- img/sidebar-open.png]`

### Search filtering
Cards filter in real-time as user types. Categories with no matches collapse.

`[TODO: screenshot -- img/sidebar-search.png]`

### Empty state
When search returns no results: centered message "No blocks found" with suggestion
to clear the search.

## Transitions

- Sidebar open/close: CSS slide transition (~200ms ease-out)
- Content swap: crossfade (~150ms) when switching between action types
- Card filtering: immediate (no animation), but categories collapse smoothly
