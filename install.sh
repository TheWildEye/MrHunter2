#!/usr/bin/env bash
# ==============================================================================
# MrHunter - OpenCode Installation Script (macOS / Linux)
# ==============================================================================
# Installs the OpenCode agents, slash commands, and skills into a project
# (./.opencode) or globally (~/.config/opencode).
#
# Usage:
#   Project-level (current workspace):
#     ./install.sh
#
#   Global-level (available in every OpenCode project):
#     ./install.sh --global
# ==============================================================================

set -e

# --- CONFIGURATION (Change this to match your repository URL) ---
GITHUB_USER="TheWildEye"
GITHUB_REPO="MrHunter2"
BRANCH="main"
REPO_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO.git"
# ================================================================

GLOBAL=false
[ "$1" == "--global" ] && GLOBAL=true

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==============================================="
echo " Installing MrHunter for OpenCode"
echo " Source: $GITHUB_USER/$GITHUB_REPO @ $BRANCH"
echo "==============================================="

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1

if [ "$GLOBAL" = true ]; then
  DEST="$HOME/.config/opencode"
  mkdir -p "$DEST/agent" "$DEST/command" "$DEST/skill"
  cp -R "$TMP_DIR/.opencode/agents/."   "$DEST/agent/"
  cp -R "$TMP_DIR/.opencode/commands/." "$DEST/command/"
  cp -R "$TMP_DIR/.opencode/skills/."   "$DEST/skill/"
  echo "Installed agents, commands, and skills to $DEST"
  echo "NOTE: merge the \"agent\" block from $TMP_DIR/opencode.json into $DEST/opencode.json"
else
  mkdir -p "./.opencode"
  cp -R "$TMP_DIR/.opencode/." "./.opencode/"
  [ -f "./opencode.json" ] || cp "$TMP_DIR/opencode.json" "./opencode.json"
  [ -f "./AGENTS.md" ] || cp "$TMP_DIR/AGENTS.md" "./AGENTS.md"
  echo "Installed OpenCode plugin into ./.opencode/"
fi

echo "==============================================="
echo " Installation Complete!"
echo " Restart OpenCode, then run any of:"
echo "   /mrhunter-security-assess   - Full SAST + DAST + secrets + compliance scan"
echo "   /mrhunter-compliance-audit  - Deep Indian regulatory compliance audit"
echo "   /mrhunter-quick-scan        - Rapid SAST & secret checks"
echo "   /mrhunter-fix-issue         - Interactively fix a specific vulnerability"
echo "==============================================="
