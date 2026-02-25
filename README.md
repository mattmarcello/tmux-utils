# claude-tmux-notify

Yellow tmux status bar indicator when Claude Code is waiting for your input. Optional desktop notifications with sound.

```
 0:zsh  1:project* 2:server  ← normal
 0:zsh  1:project*  2:server  ← window 2 has Claude waiting
```

## Install

```bash
git clone https://github.com/mattmarcello/claude-tmux-notify.git
cd claude-tmux-notify
bash install.sh
```

Or ask Claude Code to do it:

> Clone https://github.com/mattmarcello/claude-tmux-notify and run the installer.

### Requirements

- tmux
- jq (for editing settings.json)
- macOS: `terminal-notifier` (installed automatically via brew)
- Linux: `notify-send` (usually preinstalled, or `apt install libnotify-bin`)

## How it works

Two [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) drive a tmux window option:

| Hook | Action | Meaning |
|------|--------|---------|
| `Stop` | sets `@claude_ready` on the window | Claude finished — waiting for input |
| `UserPromptSubmit` | clears `@claude_ready` | User submitted a prompt — Claude is working |

tmux's `window-status-format` checks `@claude_ready` and renders a yellow highlight when set. The Stop hook also fires a desktop notification (with sound) if the window is not currently active.

### Files touched

| File | Change |
|------|--------|
| `~/.claude/claude-notify.sh` | New — notification script |
| `~/.claude/settings.json` | Adds `Stop` and `UserPromptSubmit` hooks |
| `~/.tmux.conf` | Appends one `window-status-format` line |

## Uninstall

```bash
cd claude-tmux-notify
bash uninstall.sh
```

Removes the script, hooks, and tmux config line. Clears `@claude_ready` on all windows.

## Customize

Edit `~/.claude/claude-notify.sh`:

- **Terminal icon (macOS)**: change `-sender com.mitchellh.ghostty` to your terminal's bundle ID (`com.apple.Terminal`, `com.googlecode.iterm2`, etc.)
- **Sound (macOS)**: change `-sound Funk` to another alert sound (`Ping`, `Pop`, `Glass`, etc.)
- **No desktop notifications**: delete the `terminal-notifier` / `notify-send` block — the tmux indicator still works independently
- **Indicator style**: edit the `window-status-format` in `~/.tmux.conf` — change `#[fg=black bg=yellow bold]` to any tmux style
