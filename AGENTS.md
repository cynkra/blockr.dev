# Claude Development Notes

## Feature Development Workflow

**This workflow is MANDATORY for all non-trivial features. Follow this process rigorously.**

### Phase 1: Design Document Creation and Iteration

1. **Initial design exploration**
   - Thoroughly research the feature proposal
   - Understand existing implementations in the codebase
   - Research relevant APIs, patterns, and external references
   - Gather full context before proposing solutions

2. **Design document drafting**
   - Create a comprehensive design document in `design/{package}/{feature}.md`
   - Document must cover:
     - Problem statement and motivation
     - Proposed solution with detailed API design
     - File structure and modifications required
     - Usage patterns and examples
     - Extension/plugin points for downstream packages
     - Implementation notes and potential pitfalls
     - Verification plan

3. **Human review and iteration** - **CRITICAL PHASE**
   - Present the design document to human reviewers
   - Iterate on the design based on feedback
   - **Multiple rounds of design iteration are EXPECTED and ENCOURAGED**
   - Design iterations are cheap; code rewrites are expensive
   - Address all questions about:
     - Naming conventions (functions, parameters, tags, etc.)
     - API design and ergonomics
     - Output formats and file locations
     - Backwards compatibility
     - Extension points
   - **DO NOT proceed to implementation until design is explicitly approved**
   - Lock in all details before writing code

### Phase 2: Issue and Branch Creation

4. **GitHub issue creation** - Once design is approved:
   - Create a GitHub issue with a concise description
   - Link to the design document for full details
   - Use the issue number for branch naming

5. **Branch naming convention** - **MANDATORY PATTERN**:
   - Format: `{issue-number}-{short-descriptor}`
   - Example: `140-roxygen` (NOT `140-roxygen-roclet-implementation`)
   - Keep descriptor short (1-2 words max)
   - Branch from the current working branch (may not be `main`)
   - Create via: `git checkout -b {issue-number}-{descriptor}`

### Phase 3: Implementation

6. **Systematic implementation**
   - Follow the approved design document exactly
   - Do not deviate from the design without discussion
   - If issues arise during implementation that require design changes:
     - STOP implementation
     - Document the issue
     - Propose design changes
     - Get approval before proceeding

7. **Testing and verification**
   - Follow the verification plan from the design document
   - Run all existing tests to ensure no regressions
   - Add new tests if appropriate
   - Verify the feature works as designed

### Phase 4: Pull Request Creation

8. **Commit**
   - Create atomic commits with descriptive messages
   - Use imperative mood ("Add feature" not "Added feature")
   - Keep commits focused on logical units of work
   - **DO NOT include "Co-Authored-By" comments**

9. **Push branch**
   - `git push -u origin {issue-number}-{descriptor}`

10. **Create pull request**
    - Title: Clear, concise description of what was added/changed
    - Description:
      - Summarize what changed
      - Explain benefits/motivation
      - **CRITICAL**: Include `Closes #{issue-number}` to auto-link and close issue on merge
    - Base branch: The branch you branched from (NOT necessarily `main`)
    - Link design document if helpful for reviewers

## Key Principles

1. **Design before code**: A solid, reviewed design document is **mandatory** for non-trivial features
2. **Iterate on design, not code**: Design iterations are cheap; code rewrites are expensive
3. **Human review is essential**: Design must be thoroughly reviewed and approved
4. **Lock in details first**: Implementation begins only when all design decisions are finalized
5. **Systematic workflow**: Issue → Branch → Design → Approve → Implement → Test → PR
6. **Branch naming matters**: `{issue-number}-{descriptor}` convention enables traceability
7. **Atomic commits**: Keep commits focused and use clear commit messages

## Example: Roxygen2 Roclet Feature

See [design/core/roclet.md](/workspace/design/core/roclet.md) for a complete example that followed this workflow:
- **Issue**: [#140](https://github.com/BristolMyersSquibb/blockr.core/issues/140)
- **Pull Request**: [#142](https://github.com/BristolMyersSquibb/blockr.core/pull/142)
- **Design iterations**:
  - Tag naming: `@block_descr` → `@blockDescr` (camelCase per roxygen2 conventions)
  - Output format: R code → YAML (cleaner separation of concerns)
  - Function naming: `register_block_registry` → `register_package_blocks` (clearer intent)
  - API simplification: Required paths → `system.file()` with defaults
- **Result**: Clean implementation with no major rework required

## Code Style Preferences

- Avoid nested parentheses like `({` - use single parentheses when render function body is simple
  - Good: `renderText(save_status())`
  - Avoid: `renderText({save_status()})`
  - When braces are needed, use proper indentation on separate lines:
    ```r
    renderText(
      {
        # complex logic here
        result
      }
    )
    ```

- **Write readable code, not commented code**
  - Use descriptive variable and function names that make the code self-documenting
  - Avoid descriptive comments that simply restate what the code does
  - **BAD**: `# Get constructor name` followed by `ctor_name <- ...`
  - **GOOD**: Just `ctor_name <- ...` (the variable name already says what it is)
  - **BAD**: `# Validate required tags` followed by validation code
  - **GOOD**: Just the validation code (it's obvious that's what it does)
  - Only add comments when:
    - Something unexpected or non-obvious is happening
    - There's important context that isn't clear from the code itself
    - Future maintainers might be confused without explanation
  - Section divider comments (e.g., `# Tag parsers ------`) are unnecessary - organize code with blank lines instead

- **Avoid assignment just to return**
  - Don't assign to a variable only to return it on the next line
  - **BAD**: `result <- finalize(x)` followed by `result`
  - **GOOD**: Just `finalize(x)` as the last expression
  - Only assign if you need to use the value multiple times or for debugging

- **Use vertical white-space for logical grouping**
  - Add blank lines to create logical groups of related statements
  - Makes code easier to read and understand the flow
  - Aim for aesthetically pleasing, well-organized code
  - **Rule of thumb**: After an opening `{` (function body, if-statement, etc.), add a blank line
    - Exception: Skip the blank line for short 1-2 line bodies
  - Examples:
    ```r
    # GOOD: Multi-line function with blank line after {
    process_data <- function(x) {

      validated <- validate_input(x)
      transformed <- transform(validated)

      finalize(transformed)
    }

    # GOOD: Short function, no blank line needed
    get_name <- function(x) {
      x$name
    }

    # GOOD: Multi-line if with blank line, grouping related logic
    if (is.null(ctor_name)) {

      ctor_name <- block$object$alias %||% block$object$topic

      if (is.null(ctor_name)) {
        if (!is.null(block$call)) {
          ctor_name <- as.character(block$call[[2L]])
        }
      }
    }
    ```

- **Linting is a strict requirement before committing** - all code must pass `lintr::lint()` checks

## Documentation Principles

Follow package conventions when documenting functions:

- **Group related documentation**: Use `@rdname` to group related functions in the same help file
  - Example: `register_package_blocks()` belongs with `register_block()` and `register_blocks()`
  - Related functions should share documentation rather than creating separate help files
  - This makes it easier for users to discover related functionality

- **Avoid over-documenting**: Simple wrapper functions or helpers may not need extensive separate documentation
  - If a function is straightforward, consider grouping it with related functions
  - Focus documentation effort on the primary user-facing functions

- **Use succinct names for separate help files**: If a function needs its own Rd file, use a 2-word name
  - Use the `@name` directive to control the Rd filename independently of the function name
  - Example: `@name block-roclet` creates `block-roclet.Rd` even if the function is `block_registration_roclet()`

## Testing

**IMPORTANT**: Always run and verify tests work before claiming they're complete. Don't be optimistic about test code - actually execute it to catch failures.
