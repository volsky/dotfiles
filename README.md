# dotfiles

Claude Code config synced via symlinks.

## Setup

```bash
./setup.sh   # symlink ~/.claude/ files to this repo
./sync.sh    # commit + push changes
```

## What's tracked

- `claude/CLAUDE.md` — global Claude Code instructions
- `claude/settings.json` — Claude Code settings
- `claude/mcp.json` — MCP server config
- `claude/agents/` — global agent definitions

## What's NOT tracked

Runtime/local-only: history, debug, cache, session-env, telemetry, todos, tasks, file-history, shell-snapshots, stats-cache, image-cache, paste-cache, plugins.
