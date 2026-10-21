#!/bin/sh
# Install your agent profile and skills into every AI coding tool on this machine.
# Safe to re-run; re-run after every `git pull` so built copies stay current.
# Existing real files are moved to <file>.pre-agent-config once and restored by --uninstall.
set -eu

R=$(cd "$(dirname "$0")" && pwd)
MARK="<!-- Built by agent-config-kit/install.sh."
DRY=0
UNINSTALL=0
STATUS=0
FORCE=""

usage() {
  cat <<USAGE
Usage: install.sh [--dry-run] [--uninstall] [--status] [--tool NAME]...

  --dry-run     Print what would change and touch nothing.
  --uninstall   Remove everything this script created and restore backups.
  --status      Show the state of each tool profile and change nothing.
  --tool NAME   Install for NAME even if its config folder does not exist yet.
                NAME is one of: codex, claude, gemini, agents. Repeatable.

By default a tool is configured only if its folder (~/.codex, ~/.claude,
~/.gemini, ~/.agents) already exists. Extra Claude config folders
(for example a second account) can be listed in CLAUDE_CONFIG_DIRS,
separated by colons.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --status) STATUS=1 ;;
    --tool) shift; [ $# -gt 0 ] || { usage >&2; exit 2; }; FORCE="$FORCE $1" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

say() { if [ "$DRY" = 1 ]; then echo "would $*"; else echo "$*"; fi; }

wanted() { # wanted NAME DIR: configure this tool?
  case " $FORCE " in *" $1 "*) return 0 ;; esac
  [ -d "$2" ]
}

keep_original() {
  if [ -e "$1" ] && [ ! -L "$1" ] && [ ! -e "$1.pre-agent-config" ]; then
    say "back up $1"
    [ "$DRY" = 1 ] || mv "$1" "$1.pre-agent-config"
  fi
}

link() { # link SRC DEST
  keep_original "$2"
  say "link $2"
  [ "$DRY" = 1 ] || { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }
}

# Profile plus Claude additions as one file, for tools that do not follow @imports.
build_claude() {
  keep_original "$1"
  say "build $1"
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$1")"
  rm -f "$1"
  {
    echo "$MARK Edit profile/AGENTS.md or profile/CLAUDE.md there, then re-run install.sh. -->"
    cat "$R/profile/AGENTS.md"
    echo
    cat "$R/profile/CLAUDE.md"
  } > "$1"
}

points_here() { # is $1 a symlink into this repo?
  [ -L "$1" ] && case "$(readlink "$1")" in "$R"/*) return 0 ;; esac
  return 1
}

is_built() { [ -f "$1" ] && [ ! -L "$1" ] && head -n 1 "$1" | grep -qF "$MARK"; }

restore_original() {
  if [ -e "$1.pre-agent-config" ] && [ ! -e "$1" ] && [ ! -L "$1" ]; then
    say "restore $1"
    [ "$DRY" = 1 ] || mv "$1.pre-agent-config" "$1"
  fi
}

remove_ours() {
  if points_here "$1" || is_built "$1"; then
    say "remove $1"
    [ "$DRY" = 1 ] || rm -f "$1"
  fi
  restore_original "$1"
}

skill_dirs() {
  wanted codex "$HOME/.codex" && echo "$HOME/.codex/skills"
  wanted claude "$HOME/.claude" && echo "$HOME/.claude/skills"
  wanted agents "$HOME/.agents" && echo "$HOME/.agents/skills"
  extra_claude_dirs | while IFS= read -r d; do if [ -d "$d" ]; then echo "$d/skills"; fi; done
  return 0
}

extra_claude_dirs() {
  [ -n "${CLAUDE_CONFIG_DIRS:-}" ] || return 0
  echo "$CLAUDE_CONFIG_DIRS" | tr ':' '\n' | while IFS= read -r d; do if [ -n "$d" ]; then echo "$d"; fi; done
  return 0
}

install_profiles() {
  wanted codex "$HOME/.codex" && link "$R/profile/AGENTS.md" "$HOME/.codex/AGENTS.md"
  wanted gemini "$HOME/.gemini" && link "$R/profile/AGENTS.md" "$HOME/.gemini/GEMINI.md"
  wanted claude "$HOME/.claude" && build_claude "$HOME/.claude/CLAUDE.md"
  extra_claude_dirs | while IFS= read -r d; do if [ -d "$d" ]; then build_claude "$d/CLAUDE.md"; fi; done
  return 0
}

uninstall_profiles() {
  remove_ours "$HOME/.codex/AGENTS.md"
  remove_ours "$HOME/.gemini/GEMINI.md"
  remove_ours "$HOME/.claude/CLAUDE.md"
  extra_claude_dirs | while IFS= read -r d; do remove_ours "$d/CLAUDE.md"; done
  return 0
}

# Skill folders whose name starts with _ (like _template) are not installed.
install_skills() {
  skill_dirs | while IFS= read -r dir; do
    for s in "$R"/skills/*/; do
      s=${s%/}
      case "$(basename "$s")" in _*) continue ;; esac
      dest="$dir/$(basename "$s")"
      [ "$(cd "$dest" 2>/dev/null && pwd -P)" = "$(cd "$s" && pwd -P)" ] && continue
      link "$s" "$dest"
    done
    # drop links to skills that were removed from this repo
    for l in "$dir"/*; do
      [ -L "$l" ] || continue
      case "$(readlink "$l")" in
        "$R"/skills/*) [ -e "$l" ] || { say "remove stale $l"; [ "$DRY" = 1 ] || rm -f "$l"; } ;;
      esac
    done
  done
}

uninstall_skills() {
  for dir in "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.agents/skills"; do
    for l in "$dir"/*; do remove_ours "$l"; done
  done
  extra_claude_dirs | while IFS= read -r d; do
    for l in "$d"/skills/*; do remove_ours "$l"; done
  done
  return 0
}

# One line per profile: linked, built, stale (built copy differs from a fresh build),
# foreign (a file this repo did not create) or missing.
status_line() { # status_line LABEL PATH KIND
  if [ "$3" = built ]; then
    if is_built "$2"; then
      expected=$(mktemp)
      { echo "$MARK Edit profile/AGENTS.md or profile/CLAUDE.md there, then re-run install.sh. -->"
        cat "$R/profile/AGENTS.md"; echo; cat "$R/profile/CLAUDE.md"; } > "$expected"
      if cmp -s "$expected" "$2"; then state=built; else state="stale (re-run install.sh)"; fi
      rm -f "$expected"
    elif [ -e "$2" ]; then state=foreign
    else state=missing; fi
  elif points_here "$2"; then state=linked
  elif [ -e "$2" ]; then state=foreign
  else state=missing; fi
  printf '%-10s %-8s %s\n' "$1" "$state" "$2"
}

show_status() {
  status_line codex "$HOME/.codex/AGENTS.md" link
  status_line claude "$HOME/.claude/CLAUDE.md" built
  status_line gemini "$HOME/.gemini/GEMINI.md" link
  extra_claude_dirs | while IFS= read -r d; do status_line claude "$d/CLAUDE.md" built; done
  return 0
}

if [ "$STATUS" = 1 ]; then
  show_status
  exit 0
fi

if [ "$UNINSTALL" = 1 ]; then
  uninstall_profiles
  uninstall_skills
else
  install_profiles
  install_skills
fi
