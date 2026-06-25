#!/bin/bash
# Receives Codex hook JSON on stdin; blocks curl/wget | shell commands via semgrep.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0
fi

tmpf=$(mktemp /tmp/codex-hook-XXXX.sh)
printf '#!/bin/bash\n%s\n' "$cmd" > "$tmpf"

if semgrep --config "$HOME/.codex/hooks/no-pipe-to-shell.yaml" --error "$tmpf" >/dev/null 2>&1; then
  rm -f "$tmpf"
  exit 0
fi

rm -f "$tmpf"
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Piping curl/wget into a shell is forbidden. Download the script, inspect it, then execute."}}\n'
exit 0
