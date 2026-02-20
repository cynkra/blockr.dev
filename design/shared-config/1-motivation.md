# Shared Config — Motivation

## What keeps happening

The blockr ecosystem is ~40 packages developed by a small team (3-4 people). Everyone works in `~/git/blockr/`, but there's no shared layer above the individual packages. This means:

**Skills stay personal.** Claude Code skills like `spec`, `testserver-debug`, and `workflow-builder` live in one person's `~/.claude/` or `~/git/blockr/.claude/skills/`. The rest of the team doesn't have them and doesn't know they exist. The spec process we just designed is only useful if people can actually invoke it.

**Documentation is scattered.** How to write a block, how to test, coding conventions — this knowledge lives in different places depending on who wrote it and when:

- AGENTS.md in blockr.dev (Nicolas's workflow and code style rules)
- Package-level docs in blockr.core (block API)
- Package-level docs in blockr.dplyr (how to write a blockr extension package)
- Personal MEMORY.md files (patterns learned the hard way)

A new team member — or even an existing one working in an unfamiliar package — has to piece this together from multiple sources. Or they just don't, and the code ends up inconsistent.

**Design specs have no shared home.** The spec process produces `design/` folders. Right now these live wherever the conversation happened to start. For cross-cutting concerns (like this one), there's no obvious place to put them that the whole team can see.

**Coding assistants don't know the ecosystem.** Each blockr package might have its own CLAUDE.md, but there's no common entry point that says "here's how the blockr ecosystem works, here are the conventions, here's where the documentation is." Every new Claude session starts from scratch.

## Why it matters

- **The spec process we just designed depends on this.** If skills and design docs aren't shared, the process stays theoretical.
- **Inconsistent code quality.** Some people write careful, architected code; others prototype and ship. Without shared conventions that coding assistants can enforce, the gap grows.
- **Repeated discovery.** Patterns like S3 method registration (`@method` + `@importFrom` vs bare `@export`) get re-learned painfully instead of being documented once.
- **AI amplifies divergence.** Claude follows whatever conventions it finds locally. If there's no shared source of truth, each package drifts in its own direction.

## What we want

A shared configuration layer for the blockr ecosystem that:

- Lives in a git repo the team can all access (blockr.dev is the candidate)
- Shares Claude Code skills so the whole team can use the spec process, debugging tools, etc.
- Provides common developer documentation — coding conventions, testing practices, block-writing patterns
- Gives coding assistants a common entry point to understand the ecosystem
- Doesn't impose structure on things that should stay per-package
