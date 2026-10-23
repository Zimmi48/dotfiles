# Version control: Jujutsu (jj)

Most of my repositories are colocated jj + git (look for a `.jj/` directory).
I often rewrite commits and move bookmarks with jj, including the branches
you create, sometimes while you are still working.

- Before every commit in a git worktree, check that HEAD is still on your
  branch (`git symbolic-ref -q HEAD`) and that the branch tip is the commit
  you last made. If HEAD is detached or the branch moved, I have edited it
  with jj: don't commit on the stale HEAD. Look at `jj log`, put your new
  commit on top of the current bookmark tip, and tell me what you found.
- Never rewrite, rebase or squash commits I have edited unless I ask.
- jj imports git refs automatically on every command; don't run
  `jj git import`/`export`. To make a git-only commit visible to jj, put a
  branch on it.
- Running jj inside `.claude/worktrees/<name>` operates on my *main* jj
  workspace, with paths relative to the main repo root; use `root:` paths.
- For read-only jj queries, pass `--ignore-working-copy`, so you don't
  snapshot my in-progress edits in the main workspace.
- When `jj squash` would open an editor to merge descriptions, pass
  `--use-destination-message` (or `-m`).
