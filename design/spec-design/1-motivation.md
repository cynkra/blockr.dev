# Spec Process — Motivation

## What keeps happening

When a new idea comes up (feature, config change, tooling), Claude and the developer jump straight to implementation. The conversation goes:

> "We need shared config" → "Let's move .git here" → "Wait, that broke Zed" → "OK let's try bare repos" → "Actually symlinks" → ...

Hours get spent iterating on solutions before the problem is even written down. When the first solution fails, there's no shared understanding to fall back on — just another guess.

## Why it matters

- **Wasted effort**: solutions get built, break, get reverted
- **Lost context**: the "why" lives only in conversation history, not in a durable artifact
- **No team alignment**: others can't review or contribute to a decision they never saw articulated
- **Claude amplifies the problem**: Claude is fast at generating solutions, which makes it tempting to skip the thinking

## What we want

A lightweight, repeatable process that forces problem definition before solution design. It should:

- Be simple enough to remember (not a 12-step framework)
- Produce durable artifacts (.md files) that others can read and review
- Work naturally with Claude Code (ideally as a skill) — but not depend on it. The process is a thinking discipline, not a tool feature. It should hold up even as coding assistants evolve.
- Not feel bureaucratic for small things — scale with complexity
