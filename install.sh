#!/usr/bin/env bash
# ============================================================
#  MrHunter installer (macOS / Linux)
#  Usage:
#    Project:  curl -fsSL .../install.sh | bash
#    Global :  curl -fsSL .../install.sh | bash -s -- --global
# ============================================================
set -e

REPO="https://github.com/TheWildEye/MrHunter2.git"
BRANCH="main"

GLOBAL=false
if [ "$1" = "--global" ]; then GLOBAL=true; fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==============================================="
echo " Installing MrHunter for OpenCode"
echo "==============================================="

git clone --depth 1 --branch "$BRANCH" "$REPO" "$TMP" >/dev/null 2>&1

if [ "$GLOBAL" = true ]; then
  DEST="$HOME/.config/opencode"
  mkdir -p "$DEST/agent" "$DEST/command" "$DEST/skill"
  cp -R "$TMP/MrHunter/.opencode/agents/."   "$DEST/agent/"
  cp -R "$TMP/MrHunter/.opencode/commands/." "$DEST/command/"
  cp -R "$TMP/MrHunter/.opencode/skills/."   "$DEST/skill/"
  echo " Installed globally to $DEST"
  echo " Note: merge the 'agent' block from MrHunter/opencode.json into $DEST/opencode.json"
else
  mkdir -p "./.opencode"
  cp -R "$TMP/MrHunter/.opencode/." "./.opencode/"
  [ -f "./opencode.json" ] || cp "$TMP/MrHunter/opencode.json" "./opencode.json"
  [ -f "./AGENTS.md" ]     || cp "$TMP/MrHunter/AGENTS.md"     "./AGENTS.md"
  echo " Installed into ./.opencode/"
fi

echo "==============================================="
echo " Done. Open OpenCode and run /mrhunter-quick-scan"
echo "==============================================="
