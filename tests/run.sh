#!/bin/sh
# Integration tests for install.sh. Each case runs against a throwaway $HOME.
set -u
R=$(cd "$(dirname "$0")/.." && pwd)
FAILS=0

pass() { echo "ok   $1"; }
fail() { echo "FAIL $1"; FAILS=$((FAILS + 1)); }
check() { # check NAME COMMAND...
  n=$1; shift
  if "$@" >/dev/null 2>&1; then pass "$n"; else fail "$n"; fi
}
fresh_home() { H=$(mktemp -d); export HOME="$H"; unset CLAUDE_CONFIG_DIRS; }

# 1. only tools that already have a folder are configured
fresh_home; mkdir "$H/.codex" "$H/.claude"
"$R/install.sh" >/dev/null
check "codex profile linked"     test -L "$H/.codex/AGENTS.md"
check "claude profile built"     grep -qF "Built by agent-config-kit" "$H/.claude/CLAUDE.md"
check "claude profile has both"  grep -q "Claude-specific additions" "$H/.claude/CLAUDE.md"
check "skill linked for codex"   test -L "$H/.codex/skills/code-review"
check "skill linked for claude"  test -L "$H/.claude/skills/writing-style"
check "template not installed"   test ! -e "$H/.claude/skills/_template"
check "gemini skipped"           test ! -e "$H/.gemini"

# 2. re-running changes nothing
"$R/install.sh" >/dev/null
check "idempotent"               test -L "$H/.codex/skills/code-review"

# 3. --tool forces a tool whose folder is missing
"$R/install.sh" --tool gemini >/dev/null
check "forced gemini linked"     test -L "$H/.gemini/GEMINI.md"

# 4. --dry-run touches nothing
fresh_home; mkdir "$H/.claude"
out=$("$R/install.sh" --dry-run)
check "dry run prints plan"      test -n "$out"
check "dry run writes nothing"   test ! -e "$H/.claude/CLAUDE.md"

# 5. existing files are backed up, then restored by --uninstall
fresh_home; mkdir "$H/.claude"; echo "mine" > "$H/.claude/CLAUDE.md"
"$R/install.sh" >/dev/null
check "original backed up"       grep -q mine "$H/.claude/CLAUDE.md.pre-agent-config"
"$R/install.sh" --uninstall >/dev/null
check "original restored"        grep -q mine "$H/.claude/CLAUDE.md"
check "skills removed"           test ! -e "$H/.claude/skills/code-review"

# 6. uninstall never deletes a hand-written file
fresh_home; mkdir "$H/.claude"; echo "hand written" > "$H/.claude/CLAUDE.md"
"$R/install.sh" --uninstall >/dev/null
check "hand-written kept"        grep -q "hand written" "$H/.claude/CLAUDE.md"

# 7. extra Claude accounts
fresh_home; mkdir "$H/acct"
CLAUDE_CONFIG_DIRS="$H/acct:$H/missing" "$R/install.sh" >/dev/null
check "extra account built"      test -f "$H/acct/CLAUDE.md"
check "extra account skills"     test -L "$H/acct/skills/code-review"
check "missing account skipped"  test ! -e "$H/missing"

# 8. links to removed skills are cleaned up
fresh_home; mkdir "$H/.codex"; mkdir -p "$H/.codex/skills"
ln -s "$R/skills/gone" "$H/.codex/skills/gone"
"$R/install.sh" >/dev/null
check "stale link removed"       test ! -L "$H/.codex/skills/gone"

# 9. bad flags fail
fresh_home
"$R/install.sh" --nope >/dev/null 2>&1; rc=$?
check "bad flag exits 2"         test "$rc" = 2

echo
if [ "$FAILS" = 0 ]; then echo "all passed"; else echo "$FAILS failed"; exit 1; fi
