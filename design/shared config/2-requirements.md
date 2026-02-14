# Shared Config — Requirements

## What must be true

1. **Skills are team-wide.** `/spec`, `/testserver-debug`, `/workflow-builder` work for any team member in any blockr package directory.

2. **Ecosystem conventions live in one place.** Coding style, block-writing patterns, testing practices, S3 registration rules. Not spread across AGENTS.md, per-package CLAUDE.md files, and personal MEMORY.md.

3. **Cross-cutting specs live in blockr.dev.** Design specs that aren't about a single package go in `blockr.dev/design/`.

4. **Claude gets ecosystem context in every session.** When working in any blockr package, Claude knows the shared conventions — not just what's in that package's CLAUDE.md.

5. **Per-package config still works.** Packages keep their own CLAUDE.md for package-specific things. Shared config adds to it.

6. **Setup is a few commands.** No complex tooling.

## Constraints

- Must use Claude Code's existing config mechanisms (skills, CLAUDE.md, `.claude/` directories).
- Everyone has a single parent folder containing all blockr packages. The exact path varies.
- blockr.dev already exists as a shared git repo.
- ~40 packages. The solution can't require touching all of them.

## Non-goals

- Not a monorepo migration. Each package stays its own git repo.
- Not enforcing identical config everywhere. Packages have specific needs.
- Not a build system or package manager.
