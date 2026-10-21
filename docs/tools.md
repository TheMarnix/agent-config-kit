# Where each tool reads its instructions

`install.sh` wires your `profile/` and `skills/` into these locations.

| Tool | Profile | Skills |
| --- | --- | --- |
| Codex | `~/.codex/AGENTS.md` (symlink to `profile/AGENTS.md`) | `~/.codex/skills/<name>` |
| Claude Code | `~/.claude/CLAUDE.md` (built: `AGENTS.md` + `CLAUDE.md`) | `~/.claude/skills/<name>` |
| Gemini CLI | `~/.gemini/GEMINI.md` (symlink to `profile/AGENTS.md`) | none |
| Generic | none | `~/.agents/skills/<name>` |

## Why Claude gets a built file

Some tools that read `~/.claude/CLAUDE.md` do not follow `@import` lines. The
installer concatenates the shared profile and the Claude additions into one
file with a marker on its first line. `--uninstall` only removes files that
carry the marker, so a hand-written `CLAUDE.md` is never deleted; it is backed up
to `CLAUDE.md.pre-agent-config` on first install and restored on uninstall.

## Several Claude accounts

Set `CLAUDE_CONFIG_DIRS` to a colon-separated list of extra config folders:

```sh
CLAUDE_CONFIG_DIRS="$HOME/.claude-work:$HOME/.claude-personal" ./install.sh
```

Each folder that exists gets its own built `CLAUDE.md` and linked skills.

## Adding a tool

Add one line to `install_profiles` and `uninstall_profiles`, and one to `skill_dirs` in `install.sh`, then add a case to `tests/run.sh`.
