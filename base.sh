#!/usr/bin/env bash

# ==============================================================================
# 🚀 BASE SETUP & ZSH CONFIGURATION
# ==============================================================================
# Installs base system dependencies and configures Zsh shell environment.
# ==============================================================================

set -o pipefail

echo "🚀 Starting Base Setup & Zsh Configuration..."

# =====================================================================
# 1. UPDATE & BASE DEPENDENCIES
# =====================================================================
echo "🔄 Updating system..."
sudo apt update 2>/dev/null && sudo apt upgrade -y 2>/dev/null || echo "⚠️ System update had issues"

echo "📦 Installing base dependencies..."
sudo apt install -y \
  build-essential curl wget git unzip zip htop tldr \
  ca-certificates gnupg lsb-release software-properties-common \
  libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev \
  llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev \
  zsh fzf ripgrep fd-find bat eza \
  fonts-jetbrains-mono fonts-font-awesome libfuse2 2>/dev/null && echo "✅ Base dependencies installed" || echo "⚠️ Some base dependencies failed"


# =====================================================================
# 2. GNOME TWEAKS
# =====================================================================
echo "🎨 Configuring GNOME..."
sudo apt install -y gnome-tweaks gnome-shell-extension-manager 2>/dev/null && echo "✅ GNOME tools installed" || echo "⚠️ GNOME tools install failed"

echo "👉 Extensions to enable in Extension Manager:"
echo "   - CPU Power Manager"
echo "   - Internet Speed Monitor"
echo "   - Just shows memory usage"
echo "   - Resource Monitor"
echo "   - Simple monitor"

echo ""
echo "=========================================="
echo "✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "📝 Next steps:"
echo "1. All development tools installed"
echo "2. If you haven't run base.sh yet, do so now:"
echo "   chmod +x base.sh && ./base.sh"
echo ""


# =====================================================================
# 3. ZSH CONFIGURATION
# =====================================================================
echo "🐚 Configuring Zsh..."

# Set default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh) 2>/dev/null && echo "✅ Zsh set as default shell" || echo "⚠️ Failed to set Zsh as default"
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📥 Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>/dev/null && echo "✅ Oh My Zsh installed" || echo "⚠️ Oh My Zsh install failed"
else
  echo "✅ Oh My Zsh already installed"
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "📥 Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" 2>/dev/null && echo "✅ Powerlevel10k installed" || echo "⚠️ Powerlevel10k install failed"
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc 2>/dev/null
else
  echo "✅ Powerlevel10k already installed"
fi

# Plugins
echo "📥 Installing Zsh plugins..."
SUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
HI_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
[ ! -d "$SUGGESTIONS_DIR" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$SUGGESTIONS_DIR" 2>/dev/null && echo "✅ zsh-autosuggestions installed" || echo "⚠️ zsh-autosuggestions already exists"
[ ! -d "$HI_DIR" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HI_DIR" 2>/dev/null && echo "✅ zsh-syntax-highlighting installed" || echo "⚠️ zsh-syntax-highlighting already exists"

if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc 2>/dev/null
fi

# Zoxide
if ! command -v zoxide >/dev/null 2>&1; then
  echo "📥 Installing Zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh 2>/dev/null | bash 2>/dev/null && echo "✅ Zoxide installed" || echo "⚠️ Zoxide install failed"
else
  echo "✅ Zoxide already installed"
fi

# Custom config
if ! grep -q "# PRO CONFIG START" ~/.zshrc; then
  echo "📝 Adding custom Zsh config..."
  cat << 'EOF' >> ~/.zshrc

# ---------------------------
# PRO CONFIG START
# ---------------------------

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory sharehistory hist_ignore_dups hist_reduce_blanks

eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -alF --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias l='eza -F --icons --group-directories-first'
  alias tree='eza --tree --icons'
fi

if command -v batcat >/dev/null 2>&1; then
  alias cat='batcat'
elif command -v bat >/dev/null 2>&1; then
  alias cat='bat'
fi

[ -x "$(command -v fdfind)" ] && alias fd='fdfind'
alias pi="pnpm i"
alias pd="pnpm dev"

# ---------------------------
# PRO CONFIG END
# ---------------------------
EOF
  echo "✅ Custom Zsh config added"
else
  echo "✅ Custom Zsh config already exists"
fi

echo ""
echo "=========================================="
echo "✅ BASE SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "⚠️ NEXT STEPS:"
echo "1. Run: exec zsh (to reload shell)"
echo "2. Run: p10k configure (to setup Powerlevel10k)"
echo ""
