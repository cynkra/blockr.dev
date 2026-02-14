# Sidebar

## Summary

Replace all modal dialogs in blockr.dock with a unified slide-out sidebar. Every
board action (add block, create link, manage stacks, settings) opens the same
sidebar panel instead of a modal. The sidebar uses S3 dispatch so extension packages
can add new sidebar content types without modifying blockr.dock.

## Prototype

Branch: `blockr.dock@feat/sidebar-s3-dispatch`

## Key Decisions

- **Single sidebar, not multiple.** One sidebar panel that swaps content depending
  on the action. Simpler mental model for users, simpler code.
- **S3 dispatch for content types.** `sidebar_content_ui()` is an S3 generic.
  Each content type (add-block, create-link, settings, ...) is a method. Extension
  packages just add methods.
- **Context via `session$userData`.** Sidebar content methods receive context (which
  stack, which block, etc.) through `session$userData`, not through function
  arguments. Keeps the generic signature simple.
- **No overlay.** The sidebar slides in from the left but does not dim or block the
  dock panels behind it. Users can still see their board while the sidebar is open.

## Open Questions

- Should sidebar width be responsive (narrower on small screens)?
- Should there be transition animations when switching content types within an
  already-open sidebar?
- How should keyboard focus be managed when sidebar opens/closes?
