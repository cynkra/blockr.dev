# DevContainer Setup

## Getting Started

Open this project in Zed (or any editor with devcontainer support) and open
it as a dev container. The container is based on `rocker/r-ver:4.5.2` and
includes Claude CLI, Quarto, Chromium, git, ssh, and common R system
dependencies.

The container runs as a non-root user `dev` (UID 1000) via the `remoteUser`
setting.

## User-Specific Configuration

Several config files are **gitignored** and need to be set up per user.
The `initializeCommand` creates required directories automatically, but the
files themselves need to be provided by each developer.

### SSH Keys

Place your SSH key pair in `.devcontainer/.ssh/`:

```
.devcontainer/.ssh/<keyfile>
.devcontainer/.ssh/<keyfile>.pub
```

This directory is symlinked to `/home/dev/.ssh/` on container startup.
Permissions are set automatically (`700` on the directory, `600` on private
key files).

To generate a new key:

```sh
ssh-keygen -t ed25519 -f .devcontainer/.ssh/id_ed25519 -N ""
```

Add the public key to your GitHub account under **Settings > SSH and GPG
keys**.

### Git Config

Git configuration is split into tracked (shared) and gitignored (personal)
parts.

**Tracked** (`.devcontainer/gitconfig`): Contains shared settings such as
the global gitignore. This is symlinked to `/home/dev/.gitconfig` and
includes the local config via git's `[include]` directive.

**Tracked** (`.devcontainer/gitignore`): Global gitignore patterns
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
GH_TOKEN=ghp_...
```

- `CLAUDE_CODE_OAUTH_TOKEN`: OAuth token from a Claude Max/Pro subscription
  (not an API key).
- `GH_TOKEN`: GitHub personal access token, used by `gh` CLI and GitHub API
  calls.

### R Profile

Shared R settings are in `.devcontainer/.Rprofile` (tracked), which is
symlinked to `/home/dev/.Rprofile`. This sets up the package library path,
binary package installs via Posit Package Manager, and Shiny port forwarding.

For personal R settings, create `.devcontainer/.Rprofile.local` (gitignored).
It is automatically sourced by `.devcontainer/.Rprofile` if present.

To persist R command history across container rebuilds, add the following
to `.devcontainer/.Rprofile.local`:

```r
Sys.setenv(R_HISTFILE = "/workspace/.devcontainer/.Rhistory")
```

### Shell

The container uses bash. A default `.bashrc` is provided by the image,
extended to source `.devcontainer/.bashrc.local` if it exists.

For personal shell settings (aliases, prompt, etc.), create
`.devcontainer/.bashrc.local` (gitignored).

### Claude CLI

Shared configuration for Claude Code lives in two places:

- **`CLAUDE.md`** at the repo root — project instructions, loaded
  automatically by Claude Code.
- **`.claude/skills/`** at the repo root — shared skills (slash commands).
  Each skill is a folder containing a `SKILL.md` file.

Both are tracked in git and discovered automatically at the project level.

There are **two ways** to use this shared config, depending on your setup:

#### Option A: Devcontainer (or monorepo)

Open blockr.dev in a devcontainer (or use it as the workspace root).
`CLAUDE.md` and `.claude/skills/` are at `/workspace/` and discovered
automatically — no extra setup needed.

#### Option B: Symlinks (plain parent directory)

For developers who keep `~/git/blockr/` as a plain directory with
independent repos inside, run the setup script once from the parent dir:

```sh
./blockr.dev/setup.sh
```

This creates symlinks from the parent directory to blockr.dev's config:

- `~/git/blockr/CLAUDE.md` → `blockr.dev/CLAUDE.md`
- `~/git/blockr/.claude/skills/*` → `blockr.dev/.claude/skills/*`

Updates propagate automatically via symlinks — just `git pull` in
blockr.dev.

#### User-level config

The devcontainer symlinks `.devcontainer/.claude/` to `~/.claude`
(user level). This directory holds session data, cache, and personal
settings. It is gitignored except for `settings.json`.

**Shared settings** (tracked) are in `.devcontainer/.claude/settings.json`.

Session data (history, cache, etc.) also persists in
`.devcontainer/.claude/` but is gitignored. The file `claude.json`
within is symlinked to `/home/dev/.claude.json` for user-scoped config
(MCP servers, onboarding state).

No manual setup is needed beyond providing `CLAUDE_CODE_OAUTH_TOKEN` in
the `.env` file.

### Lintr

A global lintr config is provided in `.devcontainer/.lintr` (tracked) and
bind-mounted to `/workspace/.lintr` inside the container. Lintr walks up
the directory tree from the file being linted, so the workspace-root
mount acts as a fallback for all child repos. Any repo with its own
`.lintr` file will override the global config.

## Tracked vs Gitignored Summary

| File | Tracked | Purpose |
|------|---------|---------|
| `README.md` | Yes | This file |
| `CLAUDE.md` | Yes | Project instructions |
| `.claude/skills/` | Yes | Shared Claude skills |
| `docs/` | Yes | Documentation (workflow, etc.) |
| `setup.sh` | Yes | Symlink setup for plain parent dir |
| `.devcontainer/.claude/settings.json` | Yes | Shared Claude settings |
| `.devcontainer/.claude/` (rest) | **No** | Claude session data |
| `.devcontainer/.library/` | **No** | Installed R packages |
| `.devcontainer/Dockerfile` | Yes | Container image definition |
| `.devcontainer/devcontainer.json` | Yes | DevContainer configuration |
| `.devcontainer/gitconfig` | Yes | Shared git config |
| `.devcontainer/.gitconfig.local` | **No** | Personal git identity |
| `.devcontainer/gitignore` | Yes | Global gitignore patterns |
| `.devcontainer/.Rprofile` | Yes | Shared R settings |
| `.devcontainer/.Rprofile.local` | **No** | Personal R settings |
| `.devcontainer/.Rhistory` | **No** | R command history (opt-in) |
| `.devcontainer/.lintr` | Yes | Global lintr config |
| `.devcontainer/.env` | **No** | Auth tokens |
| `.devcontainer/.ssh/` | **No** | SSH keys |
| `.devcontainer/.bashrc.local` | **No** | Personal shell settings |
