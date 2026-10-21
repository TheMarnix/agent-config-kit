# Your global instructions

<!--
This file is read by every AI coding tool on your machine (Codex, Gemini, and
Claude Code via the built CLAUDE.md). Replace everything below with your own
preferences. Keep it short: every line is read at the start of every session.
Delete this comment when you are done.
-->

## Communication

- Lead with the outcome. Keep replies short and concrete.
- Use your own spelling, date format and time zone here (for example: British spelling, DD/MM/YYYY, Europe/London).
- Say what you verified and what you assumed.

## Autonomy

- Inspect and propose before making a change I have not approved.
- Once I approve, finish the work including tests and repairs without stopping for routine permission.
- Ask only for missing access or decisions that are mine to make.

## Git

- Work on a branch. Commit in small, reviewable steps.
- Never merge, deploy or change live systems without my explicit go-ahead.
- Never commit secrets. If auth blocks a push, report the exact blocker.

## Code

- Match the style of the surrounding code.
- Run the project's tests and linter before saying work is done.
- Prefer the simplest change that solves the problem.

## Skills

- Skills live in the `skills/` folder of this repo and are linked into every tool by `install.sh`.
- When a task matches a skill's description, load that skill first.
