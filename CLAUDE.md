# claude-tmux-notify

When asked to install this, run `bash install.sh` from the repo root. The installer handles everything — copying the script, configuring Claude Code hooks, adding the tmux format, and reloading.

If the user wants to uninstall, run `bash uninstall.sh`.

If something isn't working, debug with:
```bash
# Check if the hook fires
bash -x ~/.claude/claude-notify.sh

# Check if the tmux option is set
tmux show-options -w @claude_ready

# Check the settings.json hooks
node -e 'console.log(JSON.stringify(JSON.parse(require("fs").readFileSync(process.argv[1],"utf8")).hooks,null,2))' ~/.claude/settings.json
```
