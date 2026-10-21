# agent-config-kit

One place for your instructions to AI coding agents, installed into every tool you use.

If you use more than one of Codex, Claude Code and Gemini CLI, or more than one machine, you end up with several copies of the same instructions that drift apart. This repo keeps a single profile and a single set of skills, and `install.sh` wires them into each tool.

- **One profile, every tool.** Edit `profile/AGENTS.md` once. Codex and Gemini get a symlink; Claude Code gets a built file (shared profile plus Claude-only additions).
- **Skills shared everywhere.** Each folder in `skills/` is linked into every tool's skills folder.
- **Safe.** Existing files are backed up once. `--dry-run` shows the plan. `--uninstall` removes only what this script created and restores your originals.
- **Tested.** The installer has an integration test suite that runs on Linux and macOS in CI.

## Quick start

```sh
git clone https://github.com/TheMarnix/agent-config-kit.git ~/agent-config
cd ~/agent-config
./install.sh --dry-run    # see what would change
./install.sh              # do it
```

Then edit `profile/AGENTS.md` and re-run `./install.sh` whenever you pull. Symlinked files update instantly; the built Claude file needs the re-run.

Tools are configured only if their folder already exists (`~/.codex`, `~/.claude`, `~/.gemini`, `~/.agents`). Use `--tool NAME` to force one.

Check the current state of each tool at any time:

```sh
./install.sh --status
```

`linked` and `built` are healthy. `stale` means the built Claude file no longer matches `profile/`; re-run `./install.sh`. `foreign` is a file this repo did not create.

## Layout

```
profile/AGENTS.md    shared instructions (every tool)
profile/CLAUDE.md    Claude-only additions
skills/              one folder per skill, each with a SKILL.md
skills/_template/    copy this to start a new skill (not installed)
examples/models.md   optional model-roles table
docs/tools.md        where each tool reads from, multi-account setup
tests/run.sh         installer tests
```

## Writing a skill

Copy `skills/_template` to `skills/<name>`, fill in the frontmatter and rules, and re-run `./install.sh`. The `description` line is what tools use to decide when to load the skill, so say when it applies.

Two examples are included: `writing-style` and `code-review`.

## Several machines

Keep this repo in Git, clone it on each machine, and run `./install.sh` after each pull. For a second Claude account set `CLAUDE_CONFIG_DIRS`; see [docs/tools.md](docs/tools.md).

## Uninstall

```sh
./install.sh --uninstall
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Licence: [MIT](LICENSE).
