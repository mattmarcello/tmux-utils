# claude-tmux-notify

Yellow tmux status bar indicator when Claude Code is waiting for your input.

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

Or ask Claude Code:

> Clone https://github.com/mattmarcello/claude-tmux-notify and run the installer.

### Requirements

- tmux
- node (Claude Code requires it, so you already have it)

## How it works

Two [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) drive a tmux window option:

| Hook | Action | Meaning |
|------|--------|---------|
| `Stop` | sets `@claude_ready` on the window | Claude finished — waiting for input |
| `UserPromptSubmit` | clears `@claude_ready` | User submitted a prompt — Claude is working |

tmux's `window-status-format` checks `@claude_ready` and renders a yellow highlight when set.

### Files touched

| File | Change |
|------|--------|
| `~/.claude/claude-notify.sh` | New — sets `@claude_ready` on the tmux window |
| `~/.claude/settings.json` | Adds `Stop` and `UserPromptSubmit` hooks |
| `~/.tmux.conf` | Appends one `window-status-format` line |

## Uninstall

```bash
cd claude-tmux-notify
bash uninstall.sh
```

## Customize

Edit the `window-status-format` in `~/.tmux.conf` to change the indicator style:

```tmux
# Default: yellow background
set -g window-status-format '#{?@claude_ready,#[fg=black bg=yellow bold] #I:#W #[default], #I:#W#F }'
```
