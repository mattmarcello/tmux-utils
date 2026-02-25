#!/usr/bin/env bash
set -euo pipefail

# claude-tmux-notify installer
# Installs the notification script, configures Claude Code hooks,
# and adds the tmux status bar indicator.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TMUX_CONF="$HOME/.tmux.conf"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Installing claude-tmux-notify..."

# --- 1. Copy notification script ---
cp "$SCRIPT_DIR/claude-notify.sh" "$CLAUDE_DIR/claude-notify.sh"
chmod +x "$CLAUDE_DIR/claude-notify.sh"
echo "  Copied claude-notify.sh to $CLAUDE_DIR/"

# --- 2. Install desktop notification tool ---
if [[ "$OSTYPE" == darwin* ]]; then
  if ! command -v terminal-notifier &>/dev/null; then
    echo "  Installing terminal-notifier..."
    brew install terminal-notifier
  else
    echo "  terminal-notifier already installed"
  fi
elif [[ "$OSTYPE" == linux* ]]; then
  if ! command -v notify-send &>/dev/null; then
    echo "  Installing libnotify..."
    sudo apt-get install -y libnotify-bin
  else
    echo "  notify-send already installed"
  fi
fi

# --- 3. Configure Claude Code hooks in settings.json ---
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi

# Use a temporary file for jq output
TMP="$(mktemp)"

# Add Stop hook (async, fires claude-notify.sh)
# Add UserPromptSubmit hook (clears @claude_ready)
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

# --- 4. Add tmux status format ---
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

# --- 5. Reload tmux if running ---
if tmux info &>/dev/null; then
  tmux source-file "$TMUX_CONF"
  # Clear any stale bell-monitoring options from a previous config
  tmux set -g monitor-bell off 2>/dev/null || true
  tmux set -g bell-action none 2>/dev/null || true
  tmux set -g window-status-bell-style default 2>/dev/null || true
  echo "  Reloaded tmux config"
else
  echo "  tmux not running — config will apply on next start"
fi

echo ""
echo "Done! Claude Code windows will now show a yellow indicator when waiting for input."
echo ""
echo "Customization (edit ~/.claude/claude-notify.sh):"
echo "  - Change -sender to match your terminal (com.mitchellh.ghostty, com.apple.Terminal, etc.)"
echo "  - Change -sound to a different macOS alert sound"
echo "  - Remove the notification block entirely to keep only the tmux indicator"
