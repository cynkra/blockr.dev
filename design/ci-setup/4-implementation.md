# ci-setup — Implementation

## Prototype

A working scaffold exists at `/workspace/blockr.ci/`. It has the workflows and composite actions but needs the changes listed below before it's ready.

```
blockr.ci/.github/
  actions/parse-deps/action.yaml     # composite action with layered dep resolution
  actions/parse-deps/parse-deps.sh   # bash script: registry → default-deps → PR body
  actions/registry.txt               # package name → GitHub ref mapping
  actions/rerun-deps/action.yaml     # 74 lines, from blockr.core
  actions/tests/parse-deps.bats      # 20 bats tests for parse-deps
  workflows/ci.yaml                  # all jobs
  workflows/deps-rerun.yaml          # 39 lines
```

## Changes to prototype

### 1. Fix org references

The usage comments at the top of `ci.yaml` (line 15) and `deps-rerun.yaml` (line 14) reference `BristolMyersSquibb/blockr.ci`. Change to `cynkra/blockr.ci`.

### 2. Add self-test triggers

Both workflow files currently only have `on: workflow_call`. Add direct triggers so blockr.ci tests itself on push/PR:

`ci.yaml` — add before `workflow_call`:

```yaml
on:
  push:
    branches: main
  pull_request:
    branches: main
  merge_group:
  workflow_call:
    inputs:
      ...
```

`deps-rerun.yaml` — add before `workflow_call`:

```yaml
on:
  pull_request:
    branches: main
    types: [edited]
  workflow_call:
```

When triggered directly (push/PR on blockr.ci), the inputs get their default values. The pipeline runs against the fixture package at the repo root. When called by consumers via `workflow_call`, their inputs are used.

### 3. Add R package fixture at repo root

blockr.ci needs to be a valid R package so the self-test pipeline has something to lint, check, and build pkgdown for. Files at the repo root:

**DESCRIPTION:**

```
Package: blockr.ci
Title: CI Infrastructure for blockr Packages
Version: 0.0.0.9000
Description: Reusable GitHub Actions workflows for the blockr ecosystem.
    Contains a minimal R package fixture for self-testing.
License: MIT + file LICENSE
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.3.2
Suggests:
    testthat (>= 3.0.0)
Config/testthat/edition: 3
```

**LICENSE:** standard MIT license file.

**NAMESPACE:** `export(hello)`

**R/hello.R:**

```r
#' Hello
#' @return A string.
#' @export
hello <- function() "hello"
```

**tests/testthat.R:**

```r
library(testthat)
library(blockr.ci)
test_check("blockr.ci")
```

**tests/testthat/test-hello.R:**

```r
test_that("hello works", {
  expect_equal(hello(), "hello")
})
```

### 4. Validate `uses: ./` resolution

Before any consumer migration, validate that `uses: ./.github/actions/parse-deps` in the reusable workflow resolves to blockr.ci's repo when called from a different repo.

Test: create a throwaway consumer repo that calls `cynkra/blockr.ci/.github/workflows/ci.yaml@main`. If smoke/check pass (parse-deps runs without "action not found"), the `./` resolution works. If it fails, switch all action references to `cynkra/blockr.ci/.github/actions/parse-deps@main`.

## Registry-based dependency resolution

### parse-deps action inputs

The parse-deps composite action accepts two new inputs in addition to the existing `pr-body`, `pkg`, and `base-packages`:

- **`description-path`** — path to a DESCRIPTION file. When set, package names from `Imports`, `Depends`, and `Suggests` are looked up in the registry.
- **`default-deps`** — newline-separated pak refs that override registry entries but are overridden by PR body deps.

The action passes three env vars to the script: `DESCRIPTION_PATH`, `DEFAULT_DEPS`, and `REGISTRY` (resolved via `${{ github.action_path }}/../registry.txt`).

### parse-deps.sh resolution logic

The script uses bash associative arrays (bash 4+, standard on GH Actions runners) for dedup by `owner/repo` prefix:

1. **Registry layer**: if `DESCRIPTION_PATH` is set and exists, extract package names via awk, look each up in `$REGISTRY`, call `add_dep` for matches.
2. **default-deps layer**: parse `$DEFAULT_DEPS` line by line, call `add_dep` (overwrites registry for same key).
3. **PR body layer**: parse `deps` block as before, call `add_dep` (overwrites everything for same key).
4. **Output**: `extra-packages = BASE_PACKAGES + all deps from dep_map` (insertion order preserved). `ref` is extracted from the dep_map entry matching `PKG` (not just PR body).

### ci.yaml integration

The `ci.yaml` workflow passes `description-path: DESCRIPTION` and `default-deps: ${{ inputs.default-deps }}` to parse-deps in the smoke, check, and revdep jobs. The revdep job uses `description-path: pkg/DESCRIPTION` since the checkout is at `pkg/`.

### Backward compatibility

All new inputs default to empty strings. When `DESCRIPTION_PATH` and `DEFAULT_DEPS` are both empty, behavior is identical to the original script.

## Per-repo migration

Each repo replaces its `.github/workflows/` contents with two files and deletes its `.lintr`. The revdep matrix entries below use the current org (`BristolMyersSquibb`) — adjust to match wherever the repos actually live.

### blockr.core

```yaml
# .github/workflows/ci.yaml
with:
  revdep-packages: '["BristolMyersSquibb/blockr.dock", "BristolMyersSquibb/blockr.dag"]'
  lintr-exclusions: >-
    vignettes/create-block.qmd,
    vignettes/extend-blockr.qmd,
    vignettes/blocks-registry.qmd,
    vignettes/get-started.qmd,
    vignettes/testing-blocks.qmd
```

Delete: `lint.yaml`, `smoke.yaml`, `check.yaml`, `coverage.yaml`, `pkgdown.yaml`, `revdep.yaml`, `deps-rerun.yaml`, `.github/actions/parse-deps/`, `.github/actions/rerun-deps/`, `.lintr`.

### blockr.dock

```yaml
with:
  revdep-packages: '["BristolMyersSquibb/blockr.dag"]'
  extra-pkgdown-packages: "github::DivadNojnarg/DiagrammeR"
```

### blockr.dag

```yaml
with:
  default-deps: |
    cynkra/g6R
```

No revdep — nothing depends on blockr.dag. The current revdep.yaml that checks blockr.core upstream is semantically wrong and gets dropped. Internal deps like `blockr.core` and `blockr.dock` are auto-resolved from the registry via DESCRIPTION; `g6R` is not in the registry so it needs `default-deps`.

### blockr.code

```yaml
with:
  extra-pkgdown-packages: "github::DivadNojnarg/DiagrammeR"
```

### blockr.session

```yaml
with:
  extra-pkgdown-packages: "github::DivadNojnarg/DiagrammeR"
```

### blockr (meta-package)

```yaml
jobs:
  ci:
    uses: cynkra/blockr.ci/.github/workflows/ci.yaml@main
    with:
      skip-pkgdown: true
    secrets: inherit
    permissions:
      contents: write

  publish:
    needs: ci
    if: github.event_name != 'pull_request'
    uses: ./.github/workflows/publish.yaml
    secrets: inherit
    permissions:
      contents: write
```

Keeps its local `publish.yaml`.

### blockr.dplyr, blockr.ggplot, blockr.io, blockr.ui, blockr.ai

No `with:` needed — all defaults:

```yaml
jobs:
  ci:
    uses: cynkra/blockr.ci/.github/workflows/ci.yaml@main
    secrets: inherit
    permissions:
      contents: write
```

blockr.ggplot currently has exclusions in `.lintr` for `inst/scripts/generate_screenshots.R` and `inst/scripts/generate_single_screenshot.R`. These can be passed via `lintr-exclusions` if they still exist, or dropped if the scripts are gone.

### Files deleted per repo (all repos)

- `.github/workflows/lint.yaml`
- `.github/workflows/smoke.yaml`
- `.github/workflows/check.yaml`
- `.github/workflows/coverage.yaml`
- `.github/workflows/pkgdown.yaml`
- `.github/workflows/revdep.yaml` (if present)
- `.github/workflows/deps-rerun.yaml` (if present)
- `.github/actions/` (if present, only blockr.core)
- `.lintr` (if present)

Keep: `.github/codecov.yml` (read by codecov service, not CI).

## Migration order

1. **Create `cynkra/blockr.ci`** — push the prototype with the changes above. Verify self-test CI passes.
2. **Validate `uses: ./` resolution** — test from a throwaway consumer repo.
3. **Migrate blockr.core first** — it's the canonical template, easiest to verify the output matches.
4. **Migrate remaining repos** — can be done in parallel, one PR per repo.

## Edge cases

- **repos without `CODECOV_TOKEN` secret:** coverage job will fail to upload but the step itself won't block the pipeline (covr still runs, codecov upload is best-effort). Repos need the secret configured.
- **repos without `BLOCKR_PAT` secret:** all jobs that install private deps will fail. This must be configured per-repo before migration.
- **revdep on PR vs push:** parse-deps outputs the base packages on push events (no PR body). Revdep checks downstream packages at their default branch, which is the expected behaviour on merge to main.
- **pkgdown deploy:** gated by `if: github.event_name == 'push'`. On PR and merge queue the site is built (validating it works) but not deployed. Only actual pushes to main trigger deployment.
- **check on merge queue:** the full multi-platform check matrix runs on `merge_group` events. The check job condition is `if: github.event_name != 'pull_request'`, which matches both `push` and `merge_group`. PRs only get lint + smoke (fast gate); the merge queue runs everything.
