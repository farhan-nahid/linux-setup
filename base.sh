#!/usr/bin/env bash

set -o pipefail

echo "🚀 Starting Base Setup & Zsh Configuration..."

# =====================================================================
# 1. UPDATE SYSTEM
# =====================================================================
echo "🔄 Updating system..."

sudo dpkg --configure -a 2>/dev/null
sudo apt install -f -y 2>/dev/null

if sudo apt update && sudo apt upgrade -y; then
  echo "✅ System updated"
else
  echo "⚠️ System update had issues (continuing...)"
fi

# =====================================================================
# 2. INSTALL BASE PACKAGES (SAFE LOOP)
# =====================================================================
echo "📦 Installing base dependencies..."

packages=(
  build-essential curl wget git unzip zip htop tldr
  ca-certificates gnupg lsb-release software-properties-common
  libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev
  llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev
  libffi-dev liblzma-dev
  zsh fzf ripgrep fd-find bat
  fonts-jetbrains-mono fonts-font-awesome libfuse2 zoxide
)

for pkg in "${packages[@]}"; do
  sudo apt install -y "$pkg" 2>/dev/null || echo "⚠️ Failed: $pkg"
done

echo "✅ Base dependencies step finished"

# =====================================================================
# 3. INSTALL EZA (BINARY METHOD - RELIABLE)
# =====================================================================
echo "📥 Installing eza..."

if ! command -v eza >/dev/null 2>&1; then
  set -e

  INSTALL_DIR="$HOME/.local/bin"
  TMP_DIR="/tmp/eza-install"

  mkdir -p "$INSTALL_DIR"
  rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"

  cd "$TMP_DIR" || exit

  ARCH=$(uname -m)

  case "$ARCH" in
    x86_64)
      URL="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
      ;;
    aarch64)
      URL="https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz"
      ;;
    *)
      echo "❌ Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  echo "⬇️ Downloading..."
  wget -q --show-progress "$URL" -O eza.tar.gz

  echo "📦 Extracting..."
  tar -xzf eza.tar.gz

  # Find actual binary (important fix)
  EZA_BIN=$(find . -type f -name "eza" | head -n1)

  if [ -z "$EZA_BIN" ]; then
    echo "❌ eza binary not found after extraction"
    exit 1
  fi

  echo "📁 Installing to $INSTALL_DIR..."
  mv "$EZA_BIN" "$INSTALL_DIR/eza"
  chmod +x "$INSTALL_DIR/eza"

  echo "🧹 Cleaning up..."
  rm -rf "$TMP_DIR"

  echo "✅ eza installed successfully"

else
  echo "✅ eza already installed"
fi

# Ensure PATH contains ~/.local/bin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "⚠️ Added ~/.local/bin to PATH. Restart your terminal."
fi

# =====================================================================
# 4. GNOME TOOLS
# =====================================================================
echo "🎨 Installing GNOME tools..."

sudo apt install -y gnome-tweaks gnome-shell-extension-manager 2>/dev/null \
  && echo "✅ GNOME tools installed" \
  || echo "⚠️ GNOME tools install failed"

# =====================================================================
# 5. ZSH SETUP
# =====================================================================
echo "🐚 Configuring Zsh..."

# Set default shell safely
if command -v zsh >/dev/null 2>&1; then
  if [ "$SHELL" != "$(which zsh)" ]; then
    echo "👉 Run manually if needed: chsh -s $(which zsh)"
  fi
fi

# Install Oh My Zsh safely
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📥 Installing Oh My Zsh..."
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash \
    && echo "✅ Oh My Zsh installed" \
    || echo "⚠️ Oh My Zsh failed"
else
  echo "✅ Oh My Zsh already installed"
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" \
    && echo "✅ Powerlevel10k installed" \
    || echo "⚠️ Powerlevel10k failed"

  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc 2>/dev/null
fi

# Plugins
echo "📥 Installing plugins..."

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true

if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi


# =====================================================================
# 6. CUSTOM ZSH CONFIG
# =====================================================================
if ! grep -q "PRO CONFIG START" ~/.zshrc; then
  echo "📝 Adding custom config..."

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
alias ls='eza --icons --group-directories-first'
alias ll='eza -alF --icons --group-directories-first'
alias la='eza -a --icons --group-directories-first'
alias l='eza -F --icons --group-directories-first'
alias tree='eza --tree --icons'

# bat fallback
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

  echo "✅ Custom config added"
fi

# =====================================================================
# DONE
# =====================================================================
echo ""
echo "=========================================="
echo "✅ SETUP COMPLETE!"
echo "=========================================="
echo ""
echo "👉 Run:"
echo "   exec zsh"
echo "   p10k configure"
echo ""