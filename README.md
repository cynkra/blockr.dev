# DevContainer Setup

## Getting Started

Open this project in VS Code and select "Reopen in Container" (or use the
Dev Containers CLI). The container is based on `rocker/r-ver:4.4.2` and
includes Claude CLI, git, ssh, and common R system dependencies.

## User-Specific Configuration

Several config files are **gitignored** and need to be set up per user.
The `initializeCommand` creates required directories automatically, but the
files themselves need to be provided by each developer.

### SSH Keys

Place your SSH key pair in `.devcontainer/.ssh/`:

```
.devcontainer/.ssh/id_ecdsa
.devcontainer/.ssh/id_ecdsa.pub
```

This directory is bind-mounted to `/root/.ssh/` in the container.
Permissions are set automatically (`700` on the directory, `600` on private
keys).

To generate a new key:

```sh
ssh-keygen -t ecdsa -b 256 -f .devcontainer/.ssh/id_ecdsa -N ""
```

Add the public key to your GitHub account under **Settings > SSH and GPG
keys**.

### Git Config

Git configuration is split into tracked (shared) and gitignored (personal)
parts.

**Tracked** (`.devcontainer/gitconfig`): Contains shared settings such as
the global gitignore. This is symlinked to `/root/.gitconfig` and includes
the local config via git's `[include]` directive.

**Tracked** (`.devcontainer/gitignore_global`): Global gitignore patterns
applied across all repos (e.g. `.DS_Store`).

**Gitignored** (`.devcontainer/.gitconfig.local`): Personal git settings.
Create this file with your identity:

```ini
[user]
	name = Your Name
	email = your@email.com
```

### Environment Variables

Create `.devcontainer/.env` with your tokens:

```
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
```

- `CLAUDE_CODE_OAUTH_TOKEN`: OAuth token from a Claude Max/Pro subscription
  (not an API key).
- `GITHUB_PERSONAL_ACCESS_TOKEN`: Used for the GitHub MCP server
  integration.

### R Profile

Shared R settings are in `.Rprofile` (tracked), which is symlinked to
`/root/.Rprofile`. This sets up the package library path, binary package
installs via Posit Package Manager, and Shiny port forwarding.

For personal R settings, create `.Rprofile.local` (gitignored) at the
project root. It is automatically sourced by `.Rprofile` if present.

### Claude CLI

Claude session data persists in `.claude/`, which is bind-mounted to
`/root/.claude`. The file `.claude/claude.json` is symlinked to
`/root/.claude.json` for user-scoped config (MCP servers, onboarding
state).

No manual setup is needed beyond providing `CLAUDE_CODE_OAUTH_TOKEN` in
the `.env` file.

### Lintr

A global lintr config is provided in `.lintr` (tracked) and symlinked to
`/root/.lintr`. This applies as a default to all child repos. Any repo
with its own `.lintr` file will override the global config.

## Tracked vs Gitignored Summary

| File | Tracked | Purpose |
|------|---------|---------|
| `.devcontainer/Dockerfile` | Yes | Container image definition |
| `.devcontainer/devcontainer.json` | Yes | DevContainer configuration |
| `.devcontainer/gitconfig` | Yes | Shared git config |
| `.devcontainer/gitignore_global` | Yes | Global gitignore patterns |
| `README.md` | Yes | This file |
| `.Rprofile` | Yes | Shared R settings |
| `.lintr` | Yes | Global lintr config |
| `AGENTS.md` | Yes | Agent instructions |
| `.devcontainer/.env` | **No** | Auth tokens |
| `.devcontainer/.gitconfig.local` | **No** | Personal git identity |
| `.devcontainer/.ssh/` | **No** | SSH keys |
| `.Rprofile.local` | **No** | Personal R settings |
| `.claude/` | **No** | Claude session data |
| `.library/` | **No** | Installed R packages |
