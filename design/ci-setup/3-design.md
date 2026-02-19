# ci-setup — Design

## Architecture

A single reusable workflow in `cynkra/blockr.ci` contains all jobs (lint, smoke, check, coverage, revdep, pkgdown) with their dependency chain. Consumer repos call it as one job and get the full pipeline. In the GitHub Actions UI, internal jobs appear as "ci / lint", "ci / smoke", etc. — same visibility as today, just namespaced.

Shared logic (parse-deps, rerun-deps) lives in composite actions within the same repo, referenced by the workflows via `uses: ./.github/actions/<action>`.

## Repo structure

```
cynkra/blockr.ci/
  .github/
    actions/
      parse-deps/action.yaml     # parse deps from registry, inputs, and PR body
      parse-deps/parse-deps.sh   # layered resolution script
      rerun-deps/action.yaml     # re-run jobs when deps block changes
      registry.txt               # package name → GitHub ref mapping
      tests/parse-deps.bats      # bats tests for parse-deps
    workflows/
      ci.yaml                    # reusable: full pipeline
      deps-rerun.yaml            # reusable: PR body edit trigger
  R/                             # minimal R package fixture for self-testing
  tests/
  DESCRIPTION
  NAMESPACE
```

## Merge queue

The full multi-platform check runs on `merge_group` events in addition to `push`. This means PRs enter the merge queue, GitHub runs the full check matrix, and only merges if everything passes. On regular PRs, only lint + smoke run (fast gate). The pkgdown site is only deployed on `push` to main — not from the merge queue.

Consumer repos need to add `merge_group:` to their trigger list and enable the merge queue in their branch protection rules.

## Consumer interface

Each consumer repo has two files. A ci.yaml:

```yaml
on:
  push:
    branches: main
  pull_request:
    branches: main
  merge_group:

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
| `default-deps` | string | `''` | Newline-separated pak refs always included in dependency resolution. Overrides registry; overridden by PR body deps block. |

Everything else is fixed: the job DAG, the check matrix, the lintr rules, `BLOCKR_PAT`, parse-deps in smoke/check/revdep, mermaid unlink, merge queue gating.

## Dependency resolution

Internal blockr.\* dependencies are resolved via three layers (lowest to highest priority):

1. **Registry** — a central file (`.github/actions/registry.txt`) maps R package names to GitHub refs. When a consumer lists a registered package in its DESCRIPTION `Imports`/`Depends`/`Suggests`, the corresponding GitHub ref is automatically included. This eliminates the need for `Remotes:` in DESCRIPTION.
2. **`default-deps` input** — per-repo pak refs for dependencies not in the registry (e.g., `cynkra/g6R`). Override registry entries for the same `owner/repo`.
3. **PR body `deps` block** — per-PR overrides for testing against feature branches or PRs. Override both registry and `default-deps`.

Deduplication is by `owner/repo` prefix — higher-priority layers replace lower ones for the same key. The parse-deps script uses bash associative arrays for this.

### Registry format

Simple `package_name=owner/repo` text file, one entry per line:

```
blockr.core=BristolMyersSquibb/blockr.core
blockr.dock=BristolMyersSquibb/blockr.dock
blockr.dag=BristolMyersSquibb/blockr.dag
```

Located at `.github/actions/registry.txt` so it's accessible from `parse-deps.sh` via `${{ github.action_path }}/../registry.txt`.

## Lintr config

The lint job generates `.lintr` at CI time from a canonical template (currently just `object_name_linter = NULL`) plus any exclusions passed via input. No `.lintr` files in consumer repos.

## Revdep semantics

"Check that my changes don't break downstream packages." The current repo is checked out to `pkg/`, the downstream package to `revdep/`. Dependencies are resolved from `pkg/`'s DESCRIPTION, with both `local::../pkg` and `local::../revdep` as extra packages. parse-deps resolves the revdep's git ref from the PR body.

## Self-testing

blockr.ci is itself a minimal R package (DESCRIPTION, R/, tests/ at the repo root) so the self-test pipeline has something to lint, check, and build. Its own CI calls the reusable workflows with `uses: ./.github/workflows/ci.yaml`. PRs to blockr.ci run the full pipeline against the fixture. Merging to main requires green CI.

## Composite action path resolution

In reusable workflows, `uses: ./` resolves to the **caller's** repo, not the workflow's repo. All composite action references use fully qualified paths: `uses: cynkra/blockr.ci/.github/actions/parse-deps@main`.

## Existing prototype

A working scaffold exists at `/workspace/blockr.ci/`. It covers the workflows and composite actions but does not yet include the self-test fixture package or the org-correct `cynkra/` references.
