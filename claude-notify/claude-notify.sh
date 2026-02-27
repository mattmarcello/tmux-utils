#!/usr/bin/env bash
# Claude Code turn-complete — set tmux status bar indicator
# Called from ~/.claude/settings.json Stop hook

[ -z "$TMUX_PANE" ] && exit 0

IS_ACTIVE=$(tmux display-message -t "$TMUX_PANE" -p '#{window_active}')
[ "$IS_ACTIVE" = "1" ] && exit 0

tmux set-option -w -t "$TMUX_PANE" @claude_ready 1
