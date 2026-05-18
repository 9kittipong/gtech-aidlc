#!/bin/bash
# Install AIDLC skills into a target project directory
# Usage: ./install.sh [kiro|claude-code|cursor|windsurf] [target-dir]

set -e

PLATFORM=${1:-kiro}
TARGET=${2:-.}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/.kiro/skills"

case $PLATFORM in
  kiro)        SKILLS_DIR="$TARGET/.kiro/skills" ;;
  claude-code) SKILLS_DIR="$TARGET/.claude/skills" ;;
  cursor)      SKILLS_DIR="$TARGET/.cursor/skills" ;;
  windsurf)    SKILLS_DIR="$TARGET/.windsurf/skills" ;;
  *)           echo "Usage: $0 [kiro|claude-code|cursor|windsurf] [target-dir]"; exit 1 ;;
esac

echo "Installing AIDLC skills to $SKILLS_DIR..."
mkdir -p "$SKILLS_DIR"

SKILLS=(
  aidlc
  aidlc-context
  aidlc-requirements
  aidlc-decomposition
  aidlc-foundation
  aidlc-design
  aidlc-tasks
  aidlc-implement
  aidlc-prototype
  aidlc-solutions-review
  aidlc-code-review
)

for skill in "${SKILLS[@]}"; do
  if [ -d "$SOURCE_DIR/$skill" ]; then
    echo "  Installing $skill..."
    cp -r "$SOURCE_DIR/$skill" "$SKILLS_DIR/"
  fi
done

echo ""
echo "✅ Installed ${#SKILLS[@]} skills to $SKILLS_DIR"
echo ""
echo "To start: activate the aidlc-context skill (or aidlc orchestrator)"
