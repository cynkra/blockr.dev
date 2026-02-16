# Spec Process — Design

## The process

Four phases, always in order:

1. Motivation. Why are we doing this? What's broken, or what do we want?
2. Requirements. What must be true when we're done? Constraints, scope.
3. Design. How do we get there? Options, trade-offs, decision.
4. Implementation. Build it.

Each phase produces a markdown file. Not every topic needs all four. A small thing might just need motivation + design.

Phases are sequential. You don't start requirements until motivation is written down. You don't start design until requirements are clear. This is the whole point.

## Where specs live

Each topic gets a folder: `design/<topic>/`. Files are numbered so they sort correctly. Artifacts (screenshots, code examples, CSS, mockups) live alongside the phase documents — the numbered prefix keeps spec docs at the top:

```
design/<topic>/
  1-motivation.md
  2-requirements.md
  3-design.md
  4-implementation.md
  examples/
  img/
  prototype.R
```

No per-package nesting. Some features span multiple packages. No artifact convention beyond "keep it in the topic folder."

When a topic has multiple design options and they're too big for sections in one file, split into `3-design-<option>.md` files. They sort next to `3-design.md` automatically.

## How review works

Specs go through PRs. The spec is the review artifact, not the code. This shifts review from "read 500 lines of AI-generated code" to "does this design make sense?"

## How the skill works

A Claude Code skill invoked with `/spec <topic>`. Two modes:

### Starting a new spec

`/spec shared-config` starts a conversation about motivation. Claude guides the discussion, then writes `1-motivation.md` when that phase is done. No files are created upfront for later phases.

### Resuming an existing spec

`/spec shared-config` with existing files picks up where things left off. If motivation exists but requirements doesn't, Claude starts the requirements conversation.

### Phase enforcement

The skill's main job is to stop you (and itself) from jumping ahead. If someone starts talking about implementation during the requirements phase, Claude pushes back: "We're still on requirements. Let's finish that first."

This is the part that matters most. Everything else is scaffolding.

### Writing the documents

Claude writes each phase document based on the conversation. No rigid template. The skill knows the purpose of each phase and adapts the output to the topic and the person. Different team members may structure things differently, and that's fine. We learn from each other.

## Scaling

- Trivial change: skip the skill, just do it.
- Small feature: motivation + design, maybe in one sitting.
- Medium feature: all four phases, possibly across multiple sessions.
- Large feature: all four phases, multiple people review the spec PR.

The skill doesn't enforce which level you pick. It just enforces the order once you start.

## Availability

The skill should be available to all team members across all repos. The exact mechanism for sharing skills across repos is a separate spec topic (shared-config).
