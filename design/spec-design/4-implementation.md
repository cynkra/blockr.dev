# Spec Process — Implementation

## What to build

A single file: `.claude/skills/spec/SKILL.md`

Invoked as `/spec <topic>`, where `<topic>` is the folder name under `design/`.

## File structure

### YAML frontmatter

Follow the skill format documented at https://code.claude.com/docs/en/skills:

```yaml
---
name: spec
description: |
  Guide structured spec writing through four phases: motivation, requirements,
  design, implementation. Enforces phase order and writes spec documents.
  Use when starting or continuing a design spec.
argument-hint: "[topic]"
disable-model-invocation: true
---
```

New fields:
- `argument-hint: "[topic]"` — shows the expected argument during autocomplete
- `disable-model-invocation: true` — this is a workflow you trigger manually, not something Claude should auto-activate

### Skill body

The rest of the file is markdown instructions that Claude follows when the skill is invoked. Sections below specify what those instructions must cover.

## Invocation and argument handling

The skill receives the topic name as `$ARGUMENTS`. The topic maps to a folder:

```
design/$ARGUMENTS/
```

On invocation, the skill must:

1. Check if `design/<topic>/` exists.
2. If it exists, scan for numbered phase files (`1-motivation.md`, `2-requirements.md`, `3-design.md`, `4-implementation.md`).
3. Determine the current phase (see phase detection below).
4. If the folder doesn't exist, start at phase 1 (motivation).

## Phase detection

Scan the topic folder for existing phase files. The current phase is the next one after the last completed file:

| Files found | Current phase |
|---|---|
| None | 1 — motivation |
| `1-motivation.md` | 2 — requirements |
| `1-motivation.md`, `2-requirements.md` | 3 — design |
| `1-motivation.md`, `2-requirements.md`, `3-design.md` | 4 — implementation |
| All four | Review — coherence check before coding |

Read the existing files to understand the context before starting the conversation.

## Phase enforcement

This is the skill's most important job. Rules:

- **Do not jump ahead.** If the user starts talking about implementation during the requirements phase, push back: "We're still on requirements. Let's finish that first."
- **Do not create files for later phases.** Only write the file for the current phase when it's done.
- **Be vigilant.** Claude's instinct is to solve problems. The skill must resist that instinct and keep the conversation on the current phase.
- **Allow brief forward references.** It's fine to note "we'll address that in design" — just don't start doing design work.

## Conversation flow per phase

Each phase follows the same pattern:

1. **Open the discussion.** Ask a guiding question appropriate to the phase (see phase purposes below).
2. **Have the conversation.** Explore the topic with the user. Ask follow-up questions. Challenge assumptions. Surface trade-offs.
3. **Write the document.** When the phase feels complete, tell the user you're ready to write it up. Write the file. Don't use a rigid template — adapt the structure to what was actually discussed.
4. **Transition.** After writing, ask if the user wants to continue to the next phase or stop here.

### Phase purposes

These guide what questions to ask and what the document should capture:

- **Motivation (1)**: Why are we doing this? What's broken? What do we want? The document should make someone who wasn't in the conversation understand the problem.
- **Requirements (2)**: What must be true when we're done? Constraints, scope, non-goals. Not "how" — just "what."
- **Design (3)**: How do we get there? Options considered, trade-offs, the decision. If there are multiple viable options, split into `3-design-<option>.md` files.
- **Implementation (4)**: Detailed enough to code from. File paths, data structures, edge cases. This is the last spec document — the next step is actual code.

## Document writing

- **No rigid template.** The phase purpose defines what matters, not a fixed heading structure. Different topics and different team members will produce different structures.
- **Title format:** `# <Topic> — <Phase>` (e.g., `# Shared Config — Motivation`).
- **Write from the conversation.** The document captures what was discussed, not a generic treatment of the topic.
- **Create the folder if needed.** If this is a new topic, create `design/<topic>/` before writing the first file.

## Resuming

When the topic folder already has files:

1. Read all existing phase files to understand the full context.
2. Start the conversation at the next incomplete phase.
3. Reference prior decisions naturally: "The motivation mentions X, and the requirements call for Y. Now let's figure out how to do that."

## Artifacts

Spec folders can hold artifacts (screenshots, code examples, CSS, mockups) alongside phase documents. The skill should:

- Know that artifacts may exist in the folder and consider them as context.
- When the user provides or references artifacts during conversation, suggest storing them in the topic folder.
- Not enforce any artifact organization convention — let the user decide.

## Scaling

The skill doesn't enforce how many phases a topic needs. The user decides:

- Trivial change: skip the skill entirely.
- Small feature: motivation + design, stop after phase 3.
- Medium/large feature: all four phases.

When the user says they're done after any phase, respect that. Don't push for more phases than the topic warrants.

## Edge cases

- **User invokes `/spec` without a topic:** Ask for one.
- **All four files exist:** Do a coherence review. Read all four documents, check that they tell a consistent story — motivation flows into requirements, design addresses the requirements, implementation is detailed enough to code from. Flag contradictions, gaps, or redundancies. Only after the review passes, tell the user the spec is ready to code from. Offer to fix anything flagged.
- **User wants to revise a completed phase:** Allow it. Read the existing file, discuss changes, rewrite it.
- **Multiple design options:** When the user wants to explore multiple design approaches, create `3-design-<option>.md` files instead of a single `3-design.md`.
