#!/bin/bash
# Receives Claude hook JSON on stdin; blocks curl/wget | shell commands via semgrep.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

if [ -z "$cmd" ]; then
  exit 0
fi

tmpf=$(mktemp /tmp/claude-hook-XXXX.sh)
printf '#!/bin/bash\n%s\n' "$cmd" > "$tmpf"

if semgrep --config "$HOME/.claude/hooks/no-pipe-to-shell.yaml" --error "$tmpf" 2>/dev/null; then
  rm -f "$tmpf"
  exit 0
fi

rm -f "$tmpf"
printf '{"decision":"block","reason":"Piping curl/wget into a shell is forbidden. Download the script, inspect it, then execute."}\n'
exit 0
