# Parallel Tasks — Motivation

The blockr.dev workspace has several sub-packages, each its own git repo, sharing a single R library at `.devcontainer/.library/`. Only one agent (or person) can work at a time because there's one checkout per package and one set of installed packages. A second agent editing the same files or installing a different package version breaks the first.

This bottleneck wastes capacity. Two independent tasks — say, fixing a bug in blockr.core and adding a feature to blockr.dplyr in some cases may not be run in parallel.

The goal: let multiple agents work independently, each with isolated source checkouts and R libraries, while keeping the infrastructure lightweight enough that creating a new task is cheap and switching into any task's environment is instant.
