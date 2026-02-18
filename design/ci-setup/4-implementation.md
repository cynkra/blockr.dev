# ci-setup — Implementation

## Prototype

A working scaffold exists at `/workspace/blockr.ci/`. It has the workflows and composite actions but needs the changes listed below before it's ready.

```
blockr.ci/.github/
  actions/parse-deps/action.yaml     # 67 lines, from blockr.core
  actions/rerun-deps/action.yaml     # 74 lines, from blockr.core
  workflows/ci.yaml                  # 360 lines, all jobs
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
  extra-pkgdown-packages: "github::DivadNojnarg/DiagrammeR"
```

No revdep — nothing depends on blockr.dag. The current revdep.yaml that checks blockr.core upstream is semantically wrong and gets dropped.

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
- **pkgdown deploy on PR:** gated by `if: github.event_name != 'pull_request'`. On PR the site is built (validating it works) but not deployed.
