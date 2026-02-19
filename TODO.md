# Open Issues

## Container: no way to push design work

The top-level `.git` is tmpfs'd away inside the container so the editor
doesn't see nested repos. As a side effect, agents working on design specs in
`/workspace/design` cannot interact with the `cynkra/blockr.dev` remote
(create branches, push, open PRs).

Approaches considered so far and why they don't quite work:

- **Sparse checkout / overlay**: a separate clone with `design/` symlinked
  into `/workspace`. Edits wouldn't propagate to the host; adds complexity.
- **Separate `--git-dir`**: repo metadata in a container-only path, work tree
  on the bind mount. Needs ref-syncing with the host repo to avoid dirty
  state across container restarts.
- **Ephemeral push script**: clone into a tmpdir, copy `design/`, commit,
  push, discard. No persistent state to sync, but loses granular commit
  history.

None of these are clearly right yet.
