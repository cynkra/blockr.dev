# Design Spec Template

Each feature gets its own directory under `design/{feature}/`.
Features often span multiple packages, so specs are organized by feature, not package.
Once a feature is implemented and merged, its spec moves to `design/archive/`.

## Directory structure

```
design/
  {feature}/
    overview.md        # Summary, motivation, key decisions, open questions
    ux.md              # Interaction flow, visual states, transitions (product/UX spec)
    architecture.md    # Technical design, S3 generics, file structure, API (technical spec)
    img/               # Screenshots, mockups, diagrams
    examples/          # Example code snippets, demo apps
  archive/             # Completed features (moved here after merge)
```

Not every feature needs all files. A small feature might just have `overview.md`.
A complex feature might have all of them plus additional files as needed.

## Spec types

### Product / UX Spec (`overview.md` + `ux.md`)

Written by the product owner. This is the primary review artifact -- the team
reviews the spec, not the code.

**overview.md** should contain:
1. **Summary** -- One paragraph: what the feature does and why it exists
2. **Prototype** -- Link to deployed app on blockr.cloud or branch name
3. **Key Decisions** -- Choices made and their rationale
4. **Open Questions** -- Unresolved items for spec review

**ux.md** should contain:
1. **Interaction Flow** -- Step-by-step: what the user does and what happens
2. **Visual States** -- What each state looks like (with screenshots from `img/`)
3. **Transitions** -- How the UI moves between states
4. **Edge Cases** -- Empty states, error states, loading states

### Technical Spec (`architecture.md`)

Written by the architect. Follows the pattern established in `design/core/roclet.md`:
problem, solution, API design, file structure, implementation notes, verification plan.

## Conventions

- One directory per feature: `design/{feature}/`
- Images go in `img/` subdirectory
- Spec is approved before implementation begins
- After implementation is merged, move spec to `design/archive/{feature}/`
