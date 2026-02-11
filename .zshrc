# ============================================
# ZSH4HUMANS FRAMEWORK CONFIGURATION
# ============================================
# Modern Zsh framework with sensible defaults, fast startup
# Documentation: https://github.com/romkatv/zsh4humans

# Auto-update z4h framework every 28 days (ask first)
zstyle ':z4h:' auto-update-days '28'

# Terminal behavior
zstyle ':z4h:' start-tmux       no        # Don't auto-start tmux
zstyle ':z4h:' prompt-at-bottom 'yes'     # Prompt at bottom on startup/Ctrl+L
zstyle ':z4h:bindkey' keyboard  'mac'     # Mac keyboard shortcuts

# Shell enhancements  
zstyle ':z4h:' term-shell-integration 'yes'           # Semantic markup for output
zstyle ':z4h:autosuggestions' forward-char 'accept'   # Right arrow accepts full suggestion
zstyle ':z4h:fzf-complete' recurse-dirs 'no'         # Deep directory completion

# Direnv integration (disabled - auto-loads .envrc files)
zstyle ':z4h:direnv' enable 'no'
zstyle ':z4h:direnv:success' notify 'yes'

# ============================================
# FRAMEWORK INITIALIZATION
# ============================================
# Install Oh My Zsh plugins (can be removed if unused)
z4h install ohmyzsh/ohmyzsh || return

# Initialize z4h framework - everything below runs after init
z4h init || return
# as per suggestion of anti-gravity
# if [[ -o interactive ]]; then
#   z4h init || return
# fi

# ============================================
# PATH AND ENVIRONMENT SETUP
# ============================================
path=(~/bin $path)                    # Add ~/bin to PATH
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)  # Homebrew completions (Apple Silicon)
export GPG_TTY=$TTY                   # Fix GPG signing in terminal
z4h source ~/.env.zsh                 # Load additional local config if exists

# ============================================
# KEYBOARD SHORTCUTS
# ============================================
# Command line editing
z4h bindkey undo Ctrl+/   Shift+Tab   # Undo last command line change
z4h bindkey redo Option+/             # Redo last undone change

# Directory navigation with Shift+arrows
z4h bindkey z4h-cd-back    Shift+Left    # cd to previous directory
z4h bindkey z4h-cd-forward Shift+Right   # cd to next directory  
z4h bindkey z4h-cd-up      Shift+Up      # cd to parent directory
z4h bindkey z4h-cd-down    Shift+Down    # cd into child directory

# ============================================
# CUSTOM FUNCTIONS AND ALIASES
# ============================================
autoload -Uz zmv                     # Advanced file renaming tool

# Create directory and cd into it: md dirname
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Named directories (Windows home on WSL)
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Useful aliases
alias tree='tree -a -I .git'         # Show hidden files, ignore .git
alias ls="${aliases[ls]:-ls} -A"     # Show hidden files (except . and ..)
alias pref="open ~/.zshrc -a \"Visual Studio Code\""  # Quick edit zshrc

# Dotfiles management (bare repo)
alias dotfiles='git --git-dir=$HOME/.cfg --work-tree=$HOME'
alias dotfiles-untracked='comm -23 <(ls -1dA ~/.[!.]* 2>/dev/null | xargs -I{} basename {} | sort -u) <(dotfiles ls-files | sed "s|/.*||" | sort -u)'

# ============================================
# SHELL OPTIONS
# ============================================
setopt glob_dots                      # Include hidden files in glob patterns
# setopt no_auto_menu                 # DISABLED - show completion menu on first TAB


# ============================================
# LANGUAGE-SPECIFIC SETTINGS
# ============================================
# Python: Use system-wide cache instead of project __pycache__
export PYTHONPYCACHEPREFIX="$HOME/.cache/pycache/"

# Elixir: Enable command history in IEx shell (use ↑/↓ arrows)
export ERL_AFLAGS="-kernel shell_history enabled"

# ============================================
# TERMINAL INTEGRATION
# ============================================
# iTerm2 integration - enhanced terminal features
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
# demote homebrew packages after mise. 
# export PATH="/opt/homebrew/bin:$PATH"
export PATH="$PATH:/opt/homebrew/bin"

# direnv hook
eval "$(direnv hook zsh)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Amp CLI
export PATH="/Users/siraj/.amp/bin:$PATH"

# ============================================
# VERSION MANAGERS AND LANGUAGE TOOLS
# ============================================
eval "$(mise activate zsh)"