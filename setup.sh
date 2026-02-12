#!/bin/bash
# Dotfiles setup — run this on a fresh Mac.
# Usage: curl -sL https://raw.githubusercontent.com/siraj-samsudeen/dotfiles/master/setup.sh | bash
#   — or —
# bash ~/setup.sh

set -e

DOTFILES_REPO="git@github.com:siraj-samsudeen/dotfiles.git"
CFG_DIR="$HOME/.cfg"

ask() {
  local prompt="$1"
  local default="${2:-y}"
  local reply
  if [ "$default" = "y" ]; then
    read -rp "$prompt [Y/n] " reply
    [[ -z "$reply" || "$reply" =~ ^[Yy] ]]
  else
    read -rp "$prompt [y/N] " reply
    [[ "$reply" =~ ^[Yy] ]]
  fi
}

echo "=== Dotfiles Setup ==="

# ── 1. Clone bare repo & checkout ──
if [ ! -d "$CFG_DIR" ]; then
  echo ""
  echo "Cloning dotfiles bare repo..."
  git clone --bare "$DOTFILES_REPO" "$CFG_DIR"

  if ! git --git-dir="$CFG_DIR" --work-tree="$HOME" checkout 2>/dev/null; then
    echo "Backing up conflicting files to ~/.dotfiles-backup..."
    mkdir -p ~/.dotfiles-backup
    git --git-dir="$CFG_DIR" --work-tree="$HOME" checkout 2>&1 \
      | grep "^\t" | awk '{print $1}' \
      | xargs -I{} sh -c 'mkdir -p ~/.dotfiles-backup/$(dirname "{}") && mv "$HOME/{}" ~/.dotfiles-backup/{}'
    git --git-dir="$CFG_DIR" --work-tree="$HOME" checkout
  fi

  git --git-dir="$CFG_DIR" --work-tree="$HOME" config --local status.showUntrackedFiles no
  echo "Dotfiles checked out."
else
  echo "Dotfiles repo already exists at $CFG_DIR"
fi

# ── 2. Homebrew ──
echo ""
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew: already installed"
fi

# ── 3. CLI tools (required) ──
echo ""
echo "Installing core CLI tools..."
brew install mise       # version manager (node, python, bun)
brew install direnv     # per-directory env vars (used in .zshrc)

# ── 4. Optional CLI tools ──
echo ""
if ask "Install pspg? (PostgreSQL pager, used by .psqlrc)"; then
  brew install pspg
fi

# ── 5. GUI apps (optional) ──
echo ""
if ask "Install iTerm2? (terminal emulator)"; then
  brew install --cask iterm2
fi

if ask "Install Rectangle? (window manager with keyboard shortcuts)"; then
  brew install --cask rectangle
  echo "  Import config: Rectangle > Preferences > Import > ~/RectangleConfig.json"
fi

if ask "Install Claude Code? (AI coding assistant)"; then
  brew install claude-code
fi

# ── 6. Language runtimes via mise ──
echo ""
if ask "Install language runtimes via mise? (node lts, python 3.13, bun)"; then
  eval "$(mise activate bash)"
  mise install
fi

# ── 7. Secrets file ──
echo ""
if [ ! -f ~/.secrets ]; then
  touch ~/.secrets
  chmod 600 ~/.secrets
  echo "Created ~/.secrets (chmod 600)"
  echo "  Add your tokens here: export NPM_TOKEN=\"...\""
else
  echo "~/.secrets: already exists"
fi

echo ""
echo "=== Done! Open a new terminal to load everything. ==="
