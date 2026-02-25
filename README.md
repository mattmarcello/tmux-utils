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

[Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) and a tmux window option (`@claude_ready`) work together:

1. **Stop hook** — when Claude finishes a turn, sets `@claude_ready` on the window (skipped if you're already looking at it)
2. **Notification hook** — same, but also covers permission prompts and multiple-choice questions
3. **`window-status-format`** — tmux renders a yellow highlight on windows where `@claude_ready` is set
4. **`after-select-window` hook** — clears `@claude_ready` when you switch to the window

### Files touched

| File | Change |
|------|--------|
| `~/.claude/claude-notify.sh` | New — sets `@claude_ready` on the tmux window |
| `~/.claude/settings.json` | Adds `Stop` and `Notification` hooks |
| `~/.tmux.conf` | Appends `window-status-format` + `after-select-window` hook |

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
