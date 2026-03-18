#!/usr/bin/env bash

# ==============================================================================
# 🚀 ULTIMATE UNIFIED DEV & ZSH SETUP
# ==============================================================================
# This script automates the installation of essential development tools and
# configures a professional Zsh environment.
# ==============================================================================

set -e

echo "🚀 Starting Ultimate Unified Setup..."

# -----------------------------
# 1. Update & Base Dependencies
# -----------------------------
echo "🔄 Updating system and installing base dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  build-essential curl wget git unzip zip htop tldr \
  ca-certificates gnupg lsb-release software-properties-common \
  libssl-dev zlib1g-dev libreadline-dev libsqlite3-dev \
  llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev \
  zsh fzf ripgrep fd-find bat eza \
  fonts-jetbrains-mono fonts-font-awesome

# -----------------------------
# 2. Helpers
# -----------------------------
create_desktop_entry() {
  local name=$1
  local exec_path=$2
  local comment=$3
  local desktop_file="$HOME/.local/share/applications/${name,,}.desktop"

  echo "🏷️ Creating desktop entry for $name..."
  cat <<EOF > "$desktop_file"
[Desktop Entry]
Name=$name
Exec=$exec_path
Comment=$comment
Type=Application
Terminal=false
Categories=Development;
EOF
  chmod +x "$desktop_file"
}

install_appimage() {
  local name=$1
  local url=$2
  local target="$HOME/Apps/${name,,}.AppImage"
  if [ ! -f "$target" ]; then
    echo "📥 Downloading $name..."
    wget -L "$url" -O "$target" || echo "⚠️ Failed to download $name from $url"
    if [ -f "$target" ]; then
      chmod +x "$target"
      create_desktop_entry "$name" "$target" "$name IDE/Editor"
    fi
  fi
}

# -----------------------------
# 3. Development Tools
# -----------------------------

# Pyenv
if [ ! -d "$HOME/.pyenv" ]; then
  echo "🐍 Installing pyenv..."
  curl https://pyenv.run | bash
fi
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)" || true

# Latest Python
LATEST_PYTHON=$(pyenv install --list | grep -E "^\s*3\.[0-9]+\.[0-9]+$" | tail -1 | xargs)
if ! pyenv versions | grep -q "$LATEST_PYTHON"; then
  pyenv install -s $LATEST_PYTHON
  pyenv global $LATEST_PYTHON
fi

# NVM + Node
if [ ! -d "$HOME/.nvm" ]; then
  echo "🟢 Installing Node (via NVM)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
if ! command -v node >/dev/null 2>&1; then
  nvm install node
  nvm use node
fi

# Docker Desktop (includes Docker Engine and Compose)
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker Desktop..."
  # Prerequisite: KVM
  sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
  sudo usermod -aG kvm $USER

  # Setting up repo
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update

  # Download and install Docker Desktop
  wget -O docker-desktop.deb "https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.deb"
  sudo apt install -y ./docker-desktop.deb
  rm docker-desktop.deb
fi

# -----------------------------
# 4. Applications (Browsers/Editors/Terminals/API/Communication)
# -----------------------------
echo "🌐 Installing Applications..."
mkdir -p ~/Apps

# Chrome
if ! command -v google-chrome >/dev/null 2>&1; then
  wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt install -y ./google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb
fi

# Brave
if ! command -v brave-browser >/dev/null 2>&1; then
  sudo curl -fsSLo /usr/share/keyrings/brave-browser.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo apt update && sudo apt install -y brave-browser
fi

# VS Code
if ! command -v code >/dev/null 2>&1; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
  sudo apt update && sudo apt install -y code && rm microsoft.gpg
fi

# Helper: Install DEB from URL
install_deb() {
  local name=$1
  local url=$2
  local temp_deb="/tmp/${name,,}.deb"
  echo "📥 Downloading $name (.deb)..."
  wget -O "$temp_deb" "$url"
  sudo apt install -y "$temp_deb"
  rm "$temp_deb"
}

# API Testing Tools
if ! command -v insomnia >/dev/null 2>&1; then
  echo "📥 Installing Insomnia..."
  echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all" | sudo tee /etc/apt/sources.list.d/insomnia.list
  sudo apt update && sudo apt install -y insomnia
fi

if [ ! -d "/opt/Postman" ]; then
  echo "📥 Installing Postman..."
  wget -O postman.tar.gz "https://dl.pstmn.io/download/latest/linux64"
  sudo tar -xzf postman.tar.gz -C /opt
  sudo ln -sf /opt/Postman/Postman /usr/bin/postman
  rm postman.tar.gz
  create_desktop_entry "Postman" "/usr/bin/postman" "Postman API Tool"
fi

# Requestly
if ! command -v requestly >/dev/null 2>&1; then
  echo "📥 Installing Requestly..."
  wget -O requestly.deb "https://github.com/requestly/requestly-desktop-app/releases/latest/download/requestly-desktop-app.deb"
  sudo apt install -y ./requestly.deb && rm requestly.deb
fi

# General Apps
sudo apt install -y vlc

# AnyDesk
if ! command -v anydesk >/dev/null 2>&1; then
  wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/keyrings/anydesk.gpg
  echo "deb [signed-by=/etc/apt/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
  sudo apt update && sudo apt install -y anydesk
fi

# Slack (Snap)
if ! command -v slack >/dev/null 2>&1; then
  sudo snap install slack --classic
fi

# Redis Insight (.deb)
if ! command -v redisinsight >/dev/null 2>&1; then
  install_deb "RedisInsight" "https://github.com/redis/RedisInsight/releases/download/3.2.0/Redis-Insight-linux-amd64.deb"
fi

# -----------------------------
# 5. Specialized IDEs (.deb & Repos)
# -----------------------------
echo "💻 Configuring Specialized IDEs..."

# Cursor (.deb)
if ! command -v cursor >/dev/null 2>&1; then
  install_deb "Cursor" "https://downloader.cursor.sh/linux/deb/x64"
fi

# Windsurf (Repo)
if ! command -v windsurf >/dev/null 2>&1; then
  echo "📥 Setting up Windsurf Repository..."
  wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg
  sudo install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
  rm -f windsurf-stable.gpg
  sudo apt update && sudo apt install -y windsurf
fi

# Antigravity (Repo)
if ! command -v antigravity-ai >/dev/null 2>&1; then
  echo "📥 Setting up Antigravity Repository..."
  curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
  echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
  sudo apt update && sudo apt install -y antigravity-ai
fi

# Qoder (.deb)
if ! command -v qoder >/dev/null 2>&1; then
  install_deb "Qoder" "https://download.qoder.com/release/latest/qoder_amd64.deb"
fi

# Zen Browser (Still AppImage as no official .deb exists)
mkdir -p ~/Apps
if [ ! -f ~/Apps/zen.AppImage ]; then
  install_appimage "Zen" "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage"
fi

# Terminator
if ! command -v terminator >/dev/null 2>&1; then
  sudo apt install -y terminator
fi

# Warp terminal
if ! command -v warp-terminal >/dev/null 2>&1; then
  wget https://app.warp.dev/download?package=deb -O warp.deb
  sudo apt install -y ./warp.deb && rm warp.deb
fi

# -----------------------------
# 5. GNOME Tweaks & Extensions
# -----------------------------
echo "🔧 Configuring GNOME tweaks and extensions..."
sudo apt install -y gnome-tweaks gnome-shell-extension-manager

# Note: Automatic installation of manual extensions is complex.
# We will install the manager and tell the user to enable them.
echo "👉 Extensions to enable in Extension Manager:"
echo "   - CPU Power Manager"
echo "   - Internet Speed Monitor"
echo "   - Just shows memory usage"
echo "   - Resource Monitor"
echo "   - Simple monitor"

# -----------------------------
# 6. Zsh Configuration
# -----------------------------
echo "🐚 Configuring Zsh..."

# Set Zsh default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Powerlevel10k
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

# Plugins
SUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
HI_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
[ ! -d "$SUGGESTIONS_DIR" ] && git clone https://github.com/zsh-users/zsh-autosuggestions "$SUGGESTIONS_DIR"
[ ! -d "$HI_DIR" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HI_DIR"

if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' ~/.zshrc
fi

# Zoxide
if ! command -v zoxide >/dev/null 2>&1; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Custom .zshrc additions
if ! grep -q "# PRO CONFIG START" ~/.zshrc; then
cat << 'EOF' >> ~/.zshrc

# -----------------------------
# PRO CONFIG START
# -----------------------------

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_reduce_blanks

# Navigation
eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Aliases
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Modern replacements
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

# -----------------------------
# PRO CONFIG END
# -----------------------------
EOF
fi

echo "✅ All-in-one setup complete!"
echo "⚠️ IMPORTANT: Please logout and login again for Docker changes to take effect."
echo "👉 Restart terminal or run: exec zsh"
echo "👉 Run: p10k configure"
