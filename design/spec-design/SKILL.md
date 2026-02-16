---
name: blockr-spec
description: |
  Guide structured spec writing through four phases: motivation, requirements,
  design, implementation. Enforces phase order and writes spec documents.
  Use when starting or continuing a design spec.
argument-hint: "[topic]"
---

# Spec Skill

Guide structured spec writing through four phases. Your primary job is **phase enforcement** — stop yourself and the user from jumping ahead.

## Invocation

`$ARGUMENTS` is the topic name. The spec folder is:

```
blockr.dev/design/$ARGUMENTS/
```

All specs live in the shared `blockr.dev` repo, not in individual package repos.

If `$ARGUMENTS` is empty, ask the user for a topic name before proceeding.

## On invocation

1. Check if `blockr.dev/blockr.dev/design/<topic>/` exists.
2. If it exists, read all files in the folder to understand context.
3. Scan for numbered phase files: `1-motivation.md`, `2-requirements.md`, `3-design.md`, `4-implementation.md`.
4. Determine the current phase (see phase detection).
5. If the folder doesn't exist, start at phase 1.
6. Tell the user which phase you're starting and why.

## Phase detection

The current phase is the next one after the last completed file:

| Files found | Current phase |
|---|---|
| None | 1 — motivation |
| `1-motivation.md` | 2 — requirements |
| `1-motivation.md`, `2-requirements.md` | 3 — design |
| `1-motivation.md`, `2-requirements.md`, `3-design.md` | 4 — implementation |
| All four | Review mode |

## Phase enforcement

This is your most important job. Rules:

- **Do not jump ahead.** If the user starts talking about implementation during the requirements phase, push back: "We're still on requirements — let's finish that first."
- **Do not create files for later phases.** Only write the file for the current phase when it's done.
- **Resist the urge to solve.** Your instinct is to jump to solutions. Fight it. Keep the conversation on the current phase.
- **Allow brief forward references.** It's fine to note "we'll address that in design" — just don't start doing design work.

## Conversation flow per phase

Each phase follows this pattern:

### 1. Open the discussion

Ask a guiding question appropriate to the phase. Examples:

- **Motivation:** "What's the problem we're trying to solve? What keeps happening that we want to change?"
- **Requirements:** "Given the motivation, what must be true when we're done? What are the constraints?"
- **Design:** "How should we approach this? What options do we have?"
- **Implementation:** "Let's get specific. What files, data structures, and edge cases do we need to cover?"

### 2. Have the conversation

Explore the topic with the user. Ask follow-up questions. Challenge assumptions. Surface trade-offs. Don't rush — the conversation is the point.

### 3. Write the document

When the phase feels complete, tell the user you're ready to write it up. Then write the file. Create the folder first if it doesn't exist.

### 4. Transition

After writing, ask if the user wants to continue to the next phase or stop here. Respect their choice.

## Phase purposes

These define what each phase covers and what the document should capture:

- **Motivation (1):** Why are we doing this? What's broken? What do we want? The document should make someone who wasn't in the conversation understand the problem.
- **Requirements (2):** What must be true when we're done? Constraints, scope, non-goals. Not "how" — just "what."
- **Design (3):** How do we get there? Options considered, trade-offs, the decision. If there are multiple viable approaches, create `3-design-<option>.md` files instead of a single `3-design.md`.
- **Implementation (4):** Detailed enough to code from. File paths, data structures, edge cases. This is the last spec document — the next step is actual code.

## Document writing

- **No rigid template.** The phase purpose defines what matters, not a fixed heading structure. Adapt to what was discussed.
- **Title format:** `# <Topic> — <Phase>` (e.g., `# Shared Config — Motivation`).
- **Write from the conversation.** Capture what was actually discussed, not a generic treatment of the topic.
- **Create the folder if needed.** If this is a new topic, create `blockr.dev/design/<topic>/` before writing the first file.
- **Phases 1–3: keep concise.** These are short documents — a few paragraphs, not essays. State the point and move on. Save detail for phase 4.
- **Phase 4: link to reference code.** Include file paths and line numbers to existing implementations, prototypes, or patterns being reused. If screenshots or mockups exist, reference or store them in the spec folder.
- **No LLM voice.** Write plainly. No "This is critical because...", no "It's worth noting that...", no rhetorical buildup. Just say the thing.

## Resuming an existing spec

When the topic folder already has files:

1. Read all existing phase files to understand the full context.
2. Start the conversation at the next incomplete phase.
3. Reference prior decisions naturally: "The motivation mentions X, and the requirements call for Y. Now let's figure out how to do that."

## Artifacts

Spec folders can hold artifacts (screenshots, code examples, CSS, mockups) alongside phase documents. When working with a spec:

- Check for non-phase files in the folder and consider them as context.
- When the user provides or references artifacts during conversation, suggest storing them in the topic folder.
- Don't enforce any artifact organization convention — let the user decide.

## Scaling

The user decides how many phases a topic needs:

- Trivial change: skip the skill entirely.
- Small feature: motivation + design, stop after phase 3.
- Medium/large feature: all four phases.

When the user says they're done after any phase, respect that. Don't push for more phases than the topic warrants.

## Review mode (all four files exist)

When all four phase files already exist:

1. Read all four documents.
2. Check that they tell a consistent story — motivation flows into requirements, design addresses the requirements, implementation is detailed enough to code from.
3. Flag contradictions, gaps, or redundancies.
4. Only after the review passes, tell the user the spec is ready to code from.
5. Offer to fix anything you flagged.

## Edge cases

- **No topic provided:** Ask for one. Don't guess.
- **User wants to revise a completed phase:** Allow it. Read the existing file, discuss changes, rewrite it.
- **Multiple design options:** When exploring multiple approaches, create `3-design-<option>.md` files instead of a single `3-design.md`. They sort next to each other automatically.
