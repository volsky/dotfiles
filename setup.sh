#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d%H%M%S)"

FILES=("CLAUDE.md" "settings.json" "mcp.json")

echo "Dotfiles dir: $DOTFILES_DIR"
echo ""

# Back up existing files
backed_up=false
for f in "${FILES[@]}"; do
  if [ -f "$CLAUDE_DIR/$f" ] && [ ! -L "$CLAUDE_DIR/$f" ]; then
    if [ "$backed_up" = false ]; then
      mkdir -p "$BACKUP_DIR"
      backed_up=true
      echo "Backing up to $BACKUP_DIR/"
    fi
    cp "$CLAUDE_DIR/$f" "$BACKUP_DIR/$f"
    echo "  backed up $f"
  fi
done

echo ""

# Create symlinks
for f in "${FILES[@]}"; do
  src="$DOTFILES_DIR/claude/$f"
  dst="$CLAUDE_DIR/$f"
  if [ -f "$src" ]; then
    rm -f "$dst"
    ln -s "$src" "$dst"
    echo "linked $dst -> $src"
  else
    echo "skip $f (not in dotfiles)"
  fi
done

echo ""
echo "Done. Verify with: ls -la ~/.claude/{CLAUDE.md,settings.json,mcp.json}"
