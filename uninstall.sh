#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
TMUX_CONF="$HOME/.tmux.conf"
SETTINGS="$CLAUDE_DIR/settings.json"

echo "Uninstalling claude-tmux-notify..."

# --- 1. Remove notification script ---
if [ -f "$CLAUDE_DIR/claude-notify.sh" ]; then
  rm "$CLAUDE_DIR/claude-notify.sh"
  echo "  Removed $CLAUDE_DIR/claude-notify.sh"
fi

# --- 2. Remove hooks from settings.json ---
if [ -f "$SETTINGS" ]; then
  node -e '
  const fs = require("fs");
  const settings = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  if (settings.hooks) {
    delete settings.hooks.Stop;
    delete settings.hooks.UserPromptSubmit;
    if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
  }
  fs.writeFileSync(process.argv[1], JSON.stringify(settings, null, 2) + "\n");
  ' "$SETTINGS"
  echo "  Removed hooks from $SETTINGS"
fi

# --- 3. Remove tmux config lines ---
if [ -f "$TMUX_CONF" ]; then
  TMP="$(mktemp)"
  grep -v '@claude_ready\|# Claude turn-complete indicator\|# Clear indicator when switching' "$TMUX_CONF" > "$TMP" || true
  mv "$TMP" "$TMUX_CONF"
  echo "  Removed indicator from $TMUX_CONF"
fi

# --- 4. Clear tmux state ---
if tmux info &>/dev/null; then
  tmux list-windows -a -F '#{window_id}' | while read -r wid; do
    tmux set-option -wu -t "$wid" @claude_ready 2>/dev/null || true
  done
  tmux set-hook -gu after-select-window 2>/dev/null || true
  tmux source-file "$TMUX_CONF" 2>/dev/null || true
  echo "  Cleared tmux state and reloaded config"
fi

echo ""
echo "Done. Claude Code notifications removed."
