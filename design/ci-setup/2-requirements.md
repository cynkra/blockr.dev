# ci-setup — Requirements

## Must have

- **Single source of truth.** One repo (`blockr.ci`) owns the pipeline definition — the reusable workflows and composite actions. A CI improvement is made once and applies everywhere.
- **Opt-in adoption.** Repos consume from blockr.ci by choice. No mechanism forces repos into it. A repo adopts by replacing its local workflows with thin callers that reference blockr.ci.
- **Minimal per-repo footprint.** A consumer repo needs at most two small workflow files and zero other CI config files (no local `.lintr`, no per-job workflow files). Everything else comes from blockr.ci.
- **Mandatory steps can't be individually skipped.** Lint, smoke, check, coverage, and pkgdown are structural parts of the pipeline. A consumer gets all of them or none — there's no input to disable lint or coverage. This prevents the silent-disable drift we have today.
- **Small, explicit configuration surface.** Only things that genuinely vary across repos are configurable: the reverse-dependency matrix, extra pkgdown packages, lintr file exclusions, and an escape hatch to skip pkgdown for repos with custom site builds.
- **Universal parse-deps and deps-rerun.** Every consumer gets the PR-body dependency override mechanism and the automatic re-run on deps block changes, not just blockr.core.
- **Canonical lintr config.** One set of linter rules, centrally defined and applied at CI time. Repos only control which files to exclude from linting.
- **Testable before merge.** Changes to blockr.ci are validated by CI on the blockr.ci repo itself before reaching main. Consumers track `@main`, so a broken merge would affect everyone — the safety net is on the blockr.ci side.

## Non-goals

- **Forcing adoption.** Repos outside the blockr.\* ecosystem (dockViewR, g6R, blockr.gt) use different CI patterns. They may adopt later but are not in scope.
- **Pinned versioning.** No tagging/release scheme for now. Consumers track `@main`. Pinning can be added later once the setup is stable.
- **Centralising non-CI config.** Things like `codecov.yml` (read by the codecov service, not by CI) stay per-repo. They're small, stable, and not a drift concern.
- **Supporting non-R-package repos.** The pipeline is for standard R packages. The blockr meta-package's Quarto site is handled via a local workflow extension, not by adding Quarto support to blockr.ci.
