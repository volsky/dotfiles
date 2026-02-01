#!/bin/bash
# Dotfiles setup — symlinks ~/.claude/ config from this repo
# Safe: backs up existing files before overwriting
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d%H%M%S)"

# Files to symlink (config only, not runtime data)
FILES=("CLAUDE.md" "settings.json")
# NOTE: mcp.json NOT symlinked — Claude Code doesn't follow symlinks for MCP config
# Instead, mcp.json is copied (see below)

echo "Dotfiles: $DOTFILES_DIR"
mkdir -p "$CLAUDE_DIR"

# Back up existing files
backed_up=false
for f in "${FILES[@]}" "mcp.json"; do
  if [ -f "$CLAUDE_DIR/$f" ] && [ ! -L "$CLAUDE_DIR/$f" ]; then
    if [ "$backed_up" = false ]; then
      mkdir -p "$BACKUP_DIR"
      backed_up=true
      echo "Backed up to $BACKUP_DIR/"
    fi
    cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
    echo "  backed up $f"
  fi
done

# Symlink config files
for f in "${FILES[@]}"; do
  src="$DOTFILES_DIR/claude/$f"
  dst="$CLAUDE_DIR/$f"
  if [ -f "$src" ]; then
    rm -f "$dst"
    ln -s "$src" "$dst"
    echo "linked $dst -> $src"
  fi
done

# Copy mcp.json (can't symlink — Claude Code limitation)
if [ -f "$DOTFILES_DIR/claude/mcp.json" ]; then
  cp "$DOTFILES_DIR/claude/mcp.json" "$CLAUDE_DIR/mcp.json"
  echo "copied mcp.json (symlinks not supported by Claude Code)"
fi

echo ""
echo "Done. Verify: ls -la ~/.claude/{CLAUDE.md,settings.json,mcp.json}"
echo ""
echo "NOTE: After editing mcp.json, run: cp ~/.claude/mcp.json $DOTFILES_DIR/claude/mcp.json"
echo "      Then: ./sync.sh"
