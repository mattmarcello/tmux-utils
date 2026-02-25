#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TMUX_CONF="$HOME/.tmux.conf"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing claude-tmux-notify..."

# --- 1. Copy notification script ---
mkdir -p "$CLAUDE_DIR"
cp "$SCRIPT_DIR/claude-notify.sh" "$CLAUDE_DIR/claude-notify.sh"
chmod +x "$CLAUDE_DIR/claude-notify.sh"
echo "  Copied claude-notify.sh to $CLAUDE_DIR/"

# --- 2. Configure Claude Code hooks in settings.json ---
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

TMP="$(mktemp)"
jq '
  .hooks.Stop = [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "bash ~/.claude/claude-notify.sh",
          "async": true
        }
      ]
    }
  ] |
  .hooks.UserPromptSubmit = [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "[ -n \"$TMUX_PANE\" ] && tmux set-option -wu -t \"$TMUX_PANE\" @claude_ready 2>/dev/null; true"
        }
      ]
    }
  ]
' "$SETTINGS" > "$TMP" && mv "$TMP" "$SETTINGS"
echo "  Configured hooks in $SETTINGS"

# --- 3. Add tmux status format ---
TMUX_LINE="set -g window-status-format '#{?@claude_ready,#[fg=black bg=yellow bold] #I:#W #[default], #I:#W#F }'"

if [ ! -f "$TMUX_CONF" ]; then
  touch "$TMUX_CONF"
fi

if ! grep -qF '@claude_ready' "$TMUX_CONF"; then
  printf '\n# Claude turn-complete indicator\n%s\n' "$TMUX_LINE" >> "$TMUX_CONF"
  echo "  Added window-status-format to $TMUX_CONF"
else
  echo "  window-status-format already in $TMUX_CONF (skipped)"
fi

# --- 4. Reload tmux if running ---
if tmux info &>/dev/null; then
  tmux source-file "$TMUX_CONF"
  echo "  Reloaded tmux config"
else
  echo "  tmux not running — config will apply on next start"
fi

echo ""
echo "Done! Claude Code windows will show a yellow indicator when waiting for input."
