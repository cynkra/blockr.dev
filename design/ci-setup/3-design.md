# ci-setup — Design

## Architecture

A single reusable workflow in `cynkra/blockr.ci` contains all jobs (lint, smoke, check, coverage, revdep, pkgdown) with their dependency chain. Consumer repos call it as one job and get the full pipeline. In the GitHub Actions UI, internal jobs appear as "ci / lint", "ci / smoke", etc. — same visibility as today, just namespaced.

Shared logic (parse-deps, rerun-deps) lives in composite actions within the same repo, referenced by the workflows via `uses: ./.github/actions/<action>`.

## Repo structure

```
cynkra/blockr.ci/
  .github/
    actions/
      parse-deps/action.yaml     # parse ```deps block from PR body
      rerun-deps/action.yaml     # re-run jobs when deps block changes
    workflows/
      ci.yaml                    # reusable: full pipeline
      deps-rerun.yaml            # reusable: PR body edit trigger
  R/                             # minimal R package fixture for self-testing
  tests/
  DESCRIPTION
  NAMESPACE
```

## Consumer interface

Each consumer repo has two files. A ci.yaml:

```yaml
on:
  push:
    branches: main
  pull_request:
    branches: main

name: ci

jobs:
  ci:
    uses: cynkra/blockr.ci/.github/workflows/ci.yaml@main
    with:
      revdep-packages: '["cynkra/blockr.dock"]'
    secrets: inherit
    permissions:
      contents: write
```

And a deps-rerun.yaml:

```yaml
on:
  pull_request:
    branches: main
    types: [edited]

name: deps-rerun

jobs:
  rerun:
    uses: cynkra/blockr.ci/.github/workflows/deps-rerun.yaml@main
    secrets: inherit
```

## Inputs

| Input | Type | Default | Purpose |
|---|---|---|---|
| `revdep-packages` | JSON array string | `'[]'` | Downstream packages to revdep-check. Empty skips the job. |
| `extra-pkgdown-packages` | string | `''` | Additional pak refs for pkgdown (e.g. `github::DivadNojnarg/DiagrammeR`) |
| `lintr-exclusions` | string | `''` | Comma-separated file paths to exclude from linting |
| `skip-pkgdown` | boolean | `false` | Escape hatch for repos with custom site builds |

Everything else is fixed: the job DAG, the check matrix, the lintr rules, `BLOCKR_PAT`, parse-deps in smoke/check/revdep, mermaid unlink.

## Lintr config

The lint job generates `.lintr` at CI time from a canonical template (currently just `object_name_linter = NULL`) plus any exclusions passed via input. No `.lintr` files in consumer repos.

## Revdep semantics

"Check that my changes don't break downstream packages." The current repo is checked out to `pkg/`, the downstream package to `revdep/`. Dependencies are resolved from `pkg/`'s DESCRIPTION, with both `local::../pkg` and `local::../revdep` as extra packages. parse-deps resolves the revdep's git ref from the PR body.

## Self-testing

blockr.ci is itself a minimal R package (DESCRIPTION, R/, tests/ at the repo root) so the self-test pipeline has something to lint, check, and build. Its own CI calls the reusable workflows with `uses: ./.github/workflows/ci.yaml`. PRs to blockr.ci run the full pipeline against the fixture. Merging to main requires green CI.

## Risk: composite action path resolution

The reusable workflow references composite actions via `uses: ./.github/actions/parse-deps`. In a reusable workflow, `./` should resolve to the repo containing the workflow (blockr.ci), not the caller's repo. This needs early validation. Fallback: `uses: cynkra/blockr.ci/.github/actions/parse-deps@main`.

## Existing prototype

A working scaffold exists at `/workspace/blockr.ci/`. It covers the workflows and composite actions but does not yet include the self-test fixture package or the org-correct `cynkra/` references.
