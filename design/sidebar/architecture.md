# Sidebar -- Architecture

## S3 Generic

```r
sidebar_content_ui <- function(type, ...) {
  UseMethod("sidebar_content_ui")
}
```

Each content type (e.g., `"add_block"`, `"create_link"`, `"settings"`) is a class,
and `sidebar_content_ui()` dispatches to the appropriate method. This gives us 9
content type methods in the prototype.

## File Structure

```
R/
  sidebar-api.R        # Public API: show_sidebar(), hide_sidebar(), sidebar_content_ui() generic
  sidebar-ui.R         # Sidebar UI container (the panel itself)
  sidebar-content.R    # S3 methods for each content type
  sidebar-server.R     # Sidebar server logic, event handling

inst/
  assets/
    js/
      blockr-sidebar.js   # JS module: slide animation, keyboard nav, search debounce
```

## Impact on Existing Code

Each action file (add-block, create-link, manage-stacks, etc.) currently contains
modal dialog logic. With the sidebar, each reduces to a `show_sidebar(type, ...)` call.
The prototype shows ~70% reduction in action file code.

## Extension Pattern

Any package can add a new sidebar content type:

```r
# In blockr.mypackage:
sidebar_content_ui.my_custom_type <- function(type, ...) {
  # return shiny UI
}
```

No registration needed -- S3 dispatch handles discovery automatically.

## Data Flow

1. User action triggers `show_sidebar(type = "add_block", context = list(...))`
2. `show_sidebar()` stores context in `session$userData$sidebar_context`
3. `sidebar_content_ui()` dispatches on `type` class to render the right UI
4. Content-specific server logic reads context from `session$userData`
5. On completion, content calls `hide_sidebar()` and triggers the actual operation
