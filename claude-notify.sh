#!/usr/bin/env bash
# Claude Code turn-complete notification
# Called from ~/.claude/settings.json Stop hook

# Bail if not in tmux
[ -z "$TMUX_PANE" ] && exit 0

# Get window info from the pane that just finished
WIN_IDX=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')
WIN_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}')
IS_ACTIVE=$(tmux display-message -t "$TMUX_PANE" -p '#{window_active}')

# Skip if user is already looking at this window
[ "$IS_ACTIVE" = "1" ] && exit 0

# Set status bar indicator
tmux set-option -w -t "$TMUX_PANE" @claude_ready 1

# Desktop notification (platform-specific)
if command -v terminal-notifier &>/dev/null; then
  # macOS (brew install terminal-notifier)
  terminal-notifier \
    -title "Claude done" \
    -message "Window $WIN_IDX: $WIN_NAME" \
    -sound Funk \
    -sender com.mitchellh.ghostty \
    -group "tmux-$WIN_IDX"
elif command -v notify-send &>/dev/null; then
  # Linux (apt install libnotify-bin)
  notify-send "Claude done" "Window $WIN_IDX: $WIN_NAME" \
    --hint=string:desktop-entry:ghostty
fi
