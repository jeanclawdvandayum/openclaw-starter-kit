#!/bin/bash
# OpenClaw Starter Kit — Skill Installer
# Usage: bash install.sh [workspace_dir]
#
# Installs curated general-purpose skills into ~/.openclaw/skills/
# Optionally copies workspace templates to your workspace directory.

set -e

SKILLS_DIR="$HOME/.openclaw/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="${1:-}"

echo "🦾 OpenClaw Starter Kit"
echo "========================"
echo ""

# ── Install Skills ──
echo "📦 Installing skills to $SKILLS_DIR..."

SKILL_COUNT=0
for skill_dir in "$SCRIPT_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  target="$SKILLS_DIR/$skill_name"

  if [ -d "$target" ]; then
    echo "  ⏭  $skill_name (already installed)"
  else
    cp -r "$skill_dir" "$target"
    echo "  ✅ $skill_name"
    SKILL_COUNT=$((SKILL_COUNT + 1))
  fi
done

echo ""
echo "Installed $SKILL_COUNT new skills."

# ── Copy Workspace Templates ──
if [ -n "$WORKSPACE_DIR" ]; then
  echo ""
  echo "📝 Setting up workspace templates in $WORKSPACE_DIR..."

  mkdir -p "$WORKSPACE_DIR/memory/topics"

  for template in "$SCRIPT_DIR/workspace-templates"/*.md; do
    filename=$(basename "$template")
    target="$WORKSPACE_DIR/$filename"

    if [ -f "$target" ]; then
      echo "  ⏭  $filename (already exists, skipping)"
    else
      cp "$template" "$target"
      echo "  ✅ $filename"
    fi
  done

  # Copy memory templates
  if [ ! -f "$WORKSPACE_DIR/memory/_index.md" ]; then
    cp "$SCRIPT_DIR/workspace-templates/memory/_index.md" "$WORKSPACE_DIR/memory/_index.md"
    echo "  ✅ memory/_index.md"
  fi

  if [ ! -f "$WORKSPACE_DIR/memory/learning-state.json" ]; then
    cp "$SCRIPT_DIR/workspace-templates/memory/learning-state.json" "$WORKSPACE_DIR/memory/learning-state.json"
    echo "  ✅ memory/learning-state.json"
  fi

  echo ""
  echo "Done! Edit USER.md and SOUL.md to personalize your assistant."
else
  echo ""
  echo "💡 To also set up workspace templates, run:"
  echo "   bash install.sh /path/to/your/clawd"
fi

echo ""
echo "🎉 Setup complete. Restart your OpenClaw gateway to pick up new skills."
