#!/usr/bin/env bash
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPILOT_DIR="$HOME/.copilot"
SKILLS_DIR="$TOOLKIT_DIR/skills"
AGENTS_SRC="$TOOLKIT_DIR/.agents/skills"
AGENTS_DST="$HOME/.agents/skills"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }

echo -e "\n${BOLD}Uninstalling Copilot toolkit...${NC}\n"

# Remove symlinks
for link in \
  "$COPILOT_DIR/copilot-instructions.md" \
  "$COPILOT_DIR/lsp-config.json"; do
  if [ -L "$link" ]; then
    rm "$link"
    log "Removed symlink: $link"
    # Restore backup if exists
    if [ -f "${link}.bak" ]; then
      mv "${link}.bak" "$link"
      log "Restored backup: $link"
    fi
  else
    warn "Not a symlink (skipping): $link"
  fi
done

# Remove agent skill symlinks from ~/.agents/skills
if [ -d "$AGENTS_SRC" ]; then
  for skill_dir in "$AGENTS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    dst_link="$AGENTS_DST/$skill_name"
    if [ -L "$dst_link" ] && [ "$(readlink "$dst_link")" = "${skill_dir%/}" ]; then
      rm "$dst_link"
      log "Removed agent skill symlink: $skill_name"
    fi
  done
fi

# Remove skills directory from config
CONFIG_FILE="$COPILOT_DIR/config.json"
if [ -f "$CONFIG_FILE" ] && command -v jq &>/dev/null; then
  tmp=$(mktemp)
  jq --arg dir "$SKILLS_DIR" \
    '.skillDirectories = ((.skillDirectories // []) | map(select(. != $dir)))' \
    "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
  log "Removed skills directory from config"
fi

echo -e "\n${BOLD}${GREEN}Done.${NC} Toolkit uninstalled.\n"
