# tmux-utils

Tmux utilities for working with AI coding agents (Claude Code, etc.).

## tmux-dev

Manage dev processes in named tmux panes. Start servers, read their logs, and kill them by name.

```bash
tmux-dev <name> <command...>   # Start a process in a named pane
tmux-dev logs <name> [-n N]    # Read last N lines (default 50)
tmux-dev kill <name>           # Send ctrl+c to the pane
tmux-dev list                  # Show all dev panes
```

**Examples:**

```bash
tmux-dev be pnpm dev:be        # Start backend
tmux-dev fe pnpm dev:fe        # Start frontend
tmux-dev logs be               # Check backend logs
tmux-dev be pnpm dev:be        # Restart (kills old pane first)
tmux-dev kill be               # Stop backend
tmux-dev list                  # See what's running
```

**How it works:**

- Each process runs in a tmux pane titled `dev-<name>`, tracked by stable pane ID (`%42`).
- `split-window` targets the caller's pane (`$TMUX_PANE`), so new panes always appear in the correct window — even if you're focused on a different one.
- The caller's environment is synced to the tmux session via `set-environment`, so env vars from direnv, `.env` files, or manual exports are available in the new pane.
- Panes survive agent session restarts. A new session can discover running panes with `tmux-dev list` and read their logs immediately.

**Install:**

```bash
cp tmux-dev/tmux-dev ~/.local/bin/
```

## claude-notify

Yellow tmux status bar indicator when Claude Code is waiting for your input.

```
 0:zsh  1:project* 2:server  ← normal
 0:zsh  1:project*  2:server  ← window 2 has Claude waiting (yellow)
```

Uses [Claude Code hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) to set a tmux window option (`@claude_ready`) when Claude finishes a turn, and a `window-status-format` to render the indicator.

**Install:**

```bash
bash claude-notify/install.sh
```

**Uninstall:**

```bash
bash claude-notify/uninstall.sh
```

## Requirements

- tmux
- bash
- node (for claude-notify installer only)

## License

MIT
