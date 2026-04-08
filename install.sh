#!/usr/bin/env bash
set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COPILOT_DIR="$HOME/.copilot"
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()   { echo -e "  ${YELLOW}⚠${NC}  $1"; }
header() { echo -e "\n${BOLD}$1${NC}"; }

# ── 1. Install Copilot CLI ────────────────────────────────────────────────────
header "Checking GitHub Copilot CLI..."
if command -v copilot &>/dev/null; then
  log "Copilot CLI already installed ($(copilot --version 2>/dev/null || echo 'unknown version'))"
else
  warn "Copilot CLI not found — installing..."
  curl -fsSL https://gh.io/copilot-install | bash
  log "Copilot CLI installed"
fi

# ── 2. Ensure ~/.copilot exists ───────────────────────────────────────────────
header "Setting up ~/.copilot..."
mkdir -p "$COPILOT_DIR"
log "Directory ready: $COPILOT_DIR"

# ── 3. Symlink global instructions ───────────────────────────────────────────
header "Symlinking instructions..."
INSTRUCTIONS_SRC="$TOOLKIT_DIR/instructions/copilot-instructions.md"
INSTRUCTIONS_DST="$COPILOT_DIR/copilot-instructions.md"

if [ -L "$INSTRUCTIONS_DST" ] && [ "$(readlink "$INSTRUCTIONS_DST")" = "$INSTRUCTIONS_SRC" ]; then
  log "Instructions symlink already up to date"
elif [ -f "$INSTRUCTIONS_DST" ] && [ ! -L "$INSTRUCTIONS_DST" ]; then
  warn "Backing up existing instructions to ${INSTRUCTIONS_DST}.bak"
  mv "$INSTRUCTIONS_DST" "${INSTRUCTIONS_DST}.bak"
  ln -sf "$INSTRUCTIONS_SRC" "$INSTRUCTIONS_DST"
  log "Instructions symlinked"
else
  ln -sf "$INSTRUCTIONS_SRC" "$INSTRUCTIONS_DST"
  log "Instructions symlinked"
fi

# ── 4. Symlink LSP config ─────────────────────────────────────────────────────
header "Symlinking LSP config..."
LSP_SRC="$TOOLKIT_DIR/lsp/lsp-config.json"
LSP_DST="$COPILOT_DIR/lsp-config.json"

if [ -L "$LSP_DST" ] && [ "$(readlink "$LSP_DST")" = "$LSP_SRC" ]; then
  log "LSP config symlink already up to date"
elif [ -f "$LSP_DST" ] && [ ! -L "$LSP_DST" ]; then
  warn "Backing up existing LSP config to ${LSP_DST}.bak"
  mv "$LSP_DST" "${LSP_DST}.bak"
  ln -sf "$LSP_SRC" "$LSP_DST"
  log "LSP config symlinked"
else
  ln -sf "$LSP_SRC" "$LSP_DST"
  log "LSP config symlinked"
fi

# ── 5. Register skills directory in Copilot config ───────────────────────────
header "Registering skills directory..."
SKILLS_DIR="$TOOLKIT_DIR/skills"
CONFIG_FILE="$COPILOT_DIR/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo '{}' > "$CONFIG_FILE"
fi

if command -v jq &>/dev/null; then
  CURRENT_DIRS=$(jq -r '.skillDirectories // [] | .[]' "$CONFIG_FILE" 2>/dev/null || true)
  if echo "$CURRENT_DIRS" | grep -qF "$SKILLS_DIR"; then
    log "Skills directory already registered"
  else
    tmp=$(mktemp)
    jq --arg dir "$SKILLS_DIR" \
      '.skillDirectories = ((.skillDirectories // []) + [$dir] | unique)' \
      "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
    log "Skills directory registered: $SKILLS_DIR"
  fi
else
  warn "jq not found — skipping automatic skill directory registration"
  warn "Run this inside Copilot CLI: /skills add $SKILLS_DIR"
fi

# ── 6. Ensure npx is available ───────────────────────────────────────────────
header "Checking npx / Node.js..."
if command -v npx &>/dev/null; then
  log "npx already available ($(node --version 2>/dev/null || echo 'unknown version'))"
else
  warn "npx not found. It is required to manage skills via 'npx skills'."
  read -r -p "  Install Node.js via nvm now? [y/N] " answer
  if [[ "$answer" =~ ^[yY] ]]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    # shellcheck source=/dev/null
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm install --lts
    log "Node.js installed via nvm"
  else
    warn "Skipping Node.js installation — 'npx skills' commands will not work"
  fi
fi

# ── 7. Symlink .agents/skills into ~/.agents/skills ───────────────────────────
header "Symlinking agent skills..."
AGENTS_SRC="$TOOLKIT_DIR/.agents/skills"
AGENTS_DST="$HOME/.agents/skills"

if [ -d "$AGENTS_SRC" ]; then
  mkdir -p "$AGENTS_DST"
  for skill_dir in "$AGENTS_SRC"/*/; do
    skill_name="$(basename "$skill_dir")"
    dst_link="$AGENTS_DST/$skill_name"
    if [ -L "$dst_link" ] && [ "$(readlink "$dst_link")" = "${skill_dir%/}" ]; then
      log "Agent skill symlink already up to date: $skill_name"
    else
      ln -sf "${skill_dir%/}" "$dst_link"
      log "Agent skill symlinked: $skill_name"
    fi
  done
else
  warn "No .agents/skills directory found — skipping agent skill symlinks"
fi

# ── 8. Install LSP servers (optional) ────────────────────────────────────────
header "LSP servers..."
install_lsp_server() {
  local name="$1" cmd="$2"
  if command -v "$cmd" &>/dev/null; then
    log "$name already installed"
  else
    warn "$name not found. To install: $3"
  fi
}

install_lsp_server "TypeScript LSP" "typescript-language-server" "npm install -g typescript-language-server typescript"
install_lsp_server "Python LSP (pylsp)" "pylsp"                  "pip install 'python-lsp-server[all]'"
install_lsp_server "Rust Analyzer" "rust-analyzer"               "rustup component add rust-analyzer  OR  see https://rust-analyzer.github.io/manual.html#installation"

# ── Done ──────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}✨ Copilot toolkit installed!${NC}\n"
echo -e "  Skills dir : $SKILLS_DIR"
echo -e "  Agent skills: $AGENTS_DST (symlinked from $AGENTS_SRC)"
echo -e "  Instructions: $INSTRUCTIONS_DST → $INSTRUCTIONS_SRC"
echo -e "  LSP config  : $LSP_DST → $LSP_SRC"
echo -e ""
echo -e "  Next steps:"
echo -e "  • Run ${BOLD}copilot${NC} to start the CLI"
echo -e "  • Use ${BOLD}/skills${NC} to verify skills are loaded"
echo -e "  • Add your own skills in ${BOLD}skills/<name>/SKILL.md${NC}"
echo -e "  • Customize ${BOLD}instructions/copilot-instructions.md${NC} with your preferences"
echo ""
