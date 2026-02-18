# blockr.ci — Motivation

The blockr ecosystem has ~11 R packages that all run the same CI pipeline: lint, smoke test, multi-platform check, coverage, pkgdown, and (for some) reverse-dependency checks. The pipeline originated in blockr.core and was copied into each new repo.

Without a single source of truth, the copies have drifted:

- **Features don't propagate.** parse-deps (override dependency versions via PR body) and deps-rerun (re-trigger jobs when the deps block changes) only exist in blockr.core. Every other repo lacks them.
- **Steps get silently disabled.** Linting is commented out in blockr.dplyr and blockr.io. No mechanism catches this.
- **Configs diverge.** Lintr configs differ across every repo (different linters disabled, different line lengths, different exclusions). Some repos use `GITHUB_TOKEN` where others use `BLOCKR_PAT`.
- **Structural inconsistencies accumulate.** blockr.ggplot triggers on `[main, master]`, has a 5th check matrix entry, and adds `build_args` to smoke where others don't. blockr.dag's revdep checks blockr.core upstream, which is semantically backwards. These aren't intentional choices — they're copy-paste artifacts.
- **Improvements are expensive.** Fixing or improving anything in the pipeline means touching 11 repos. In practice this means it doesn't happen, and the drift gets worse.

The goal is a single CI definition that all blockr.\* packages consume, with a minimal per-repo configuration surface for the things that genuinely differ (like which downstream packages to reverse-dep check).
