#!/usr/bin/env bash

# ==============================================================================
# 🚀 DEVELOPMENT TOOLS & APPLICATIONS SETUP
# ==============================================================================
# Installs development tools, browsers, IDEs, and communication applications.
# Run base.sh first before running this script!
# ==============================================================================

set -o pipefail

echo "🚀 Starting Development Tools & Applications Setup..."

# Error handling
trap 'echo "⚠️ Script encountered an error at line $LINENO"' ERR

mkdir -p ~/.local/share/applications ~/Apps

# =====================================================================
# HELPER FUNCTIONS
# =====================================================================

create_desktop_entry() {
  local name=$1
  local exec_path=$2
  local comment=$3
  local desktop_file="$HOME/.local/share/applications/${name,,}.desktop"

  mkdir -p "$HOME/.local/share/applications"
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

install_deb() {
  local name=$1
  local url=$2
  local temp_deb="/tmp/${name,,}.deb"
  echo "📥 Downloading $name (.deb)..."
  if wget -O "$temp_deb" "$url" 2>/dev/null; then
    if sudo apt install -y "$temp_deb" 2>/dev/null; then
      rm -f "$temp_deb"
      echo "✅ $name installed"
      return 0
    else
      echo "⚠️ Failed to install $name"
      rm -f "$temp_deb"
      return 1
    fi
  else
    echo "⚠️ Failed to download $name"
    return 1
  fi
}

install_appimage() {
  local name=$1
  local url=$2
  local target="$HOME/Apps/${name,,}.AppImage"
  if [ ! -f "$target" ]; then
    echo "📥 Downloading $name..."
    if wget -L "$url" -O "$target" 2>/dev/null; then
      chmod +x "$target"
      create_desktop_entry "$name" "$target" "$name"
      echo "✅ $name installed"
    else
      echo "⚠️ Failed to download $name"
      rm -f "$target"
    fi
  fi
}

# =====================================================================
# 1. DEVELOPMENT TOOLS
# =====================================================================

# Pyenv
if [ ! -d "$HOME/.pyenv" ]; then
  echo "🐍 Installing pyenv..."
  curl https://pyenv.run 2>/dev/null | bash 2>/dev/null && echo "✅ Pyenv installed" || echo "⚠️ Failed to install pyenv"
fi

# NVM + Node
if [ ! -d "$HOME/.nvm" ]; then
  echo "🟢 Installing Node (via NVM)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh 2>/dev/null | bash 2>/dev/null && echo "✅ NVM installed" || echo "⚠️ Failed to install NVM"
fi

# =====================================================================
# 2. DOCKER
# =====================================================================
echo "🐳 Installing Docker..."

if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings 2>/dev/null
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg 2>/dev/null | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.gpg 2>/dev/null

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  if sudo apt update 2>/dev/null && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null; then
    sudo usermod -aG docker "$USER" 2>/dev/null
    echo "✅ Docker installed"
    echo "ℹ️ Re-login required for Docker group permissions"
  else
    echo "⚠️ Docker install failed"
  fi
else
  echo "✅ Docker already installed"
fi


# =====================================================================
# 3. BROWSERS
# =====================================================================
echo "🌐 Installing Browsers..."

# Chrome
if ! command -v google-chrome >/dev/null 2>&1; then
  if wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; then
    sudo apt install -y ./google-chrome-stable_current_amd64.deb 2>/dev/null && rm google-chrome-stable_current_amd64.deb && echo "✅ Chrome installed" || echo "⚠️ Chrome install failed"
  else
    echo "⚠️ Failed to download Chrome"
  fi
else
  echo "✅ Chrome already installed"
fi

# Brave
if ! command -v brave-browser >/dev/null 2>&1; then
  sudo curl -fsSLo /usr/share/keyrings/brave-browser.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2>/dev/null
  echo "deb [signed-by=/usr/share/keyrings/brave-browser.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
  sudo apt update 2>/dev/null && sudo apt install -y brave-browser 2>/dev/null && echo "✅ Brave installed" || echo "⚠️ Brave install failed"
else
  echo "✅ Brave already installed"
fi

# =====================================================================
# 4. IDES
# =====================================================================
echo "🔧 Installing IDEs..."

# VS Code
if ! command -v code >/dev/null 2>&1; then
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc 2>/dev/null | gpg --dearmor > microsoft.gpg 2>/dev/null
  if [ -f microsoft.gpg ]; then
    sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/ 2>/dev/null
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt update 2>/dev/null && sudo apt install -y code 2>/dev/null && echo "✅ VS Code installed" || echo "⚠️ VS Code install failed"
    rm -f microsoft.gpg
  fi
else
  echo "✅ VS Code already installed"
fi

# Antigravity
if ! command -v antigravity >/dev/null 2>&1; then
  echo "🛰️ Installing Antigravity..."

  sudo mkdir -p /etc/apt/keyrings

  if curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg 2>/dev/null; then

    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
      sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

    if sudo apt update 2>/dev/null && sudo apt install -y antigravity 2>/dev/null; then
      echo "✅ Antigravity installed"
    else
      echo "⚠️ Antigravity install failed"
    fi
  else
    echo "⚠️ Failed to add Antigravity repository key"
  fi
else
  echo "✅ Antigravity already installed"
fi

# Qoder
if [ ! -f /usr/bin/qoder ]; then
  install_deb "Qoder" "https://download.qoder.com/release/latest/qoder_amd64.deb"
fi

# =====================================================================
# 3. API & COMMUNICATION TOOLS
# =====================================================================
echo "🔧 Installing API & Communication Tools..."


# Postman
if [ ! -d "/opt/Postman" ]; then
  if wget -O postman.tar.gz "https://dl.pstmn.io/download/latest/linux64" 2>/dev/null; then
    sudo mkdir -p /opt
    sudo tar -xzf postman.tar.gz -C /opt 2>/dev/null && rm postman.tar.gz
    sudo ln -sf /opt/Postman/Postman /usr/bin/postman 2>/dev/null
    create_desktop_entry "Postman" "/usr/bin/postman" "Postman API Tool"
    echo "✅ Postman installed"
  else
    echo "⚠️ Failed to download Postman"
  fi
fi

# Slack
if ! command -v slack >/dev/null 2>&1; then
  install_deb "Slack" "https://downloads.slack-edge.com/desktop-releases/linux/x64/latest/slack-desktop-amd64.deb"
else
  echo "✅ Slack already installed"
fi

# Redis Insight
if ! command -v redisinsight >/dev/null 2>&1; then
  install_deb "RedisInsight" "https://github.com/redis/RedisInsight/releases/download/3.2.0/Redis-Insight-linux-amd64.deb"
fi


# =====================================================================
# 5. TERMINALS
# =====================================================================
echo "🖥️ Installing Terminals..."

# Terminator
if ! command -v terminator >/dev/null 2>&1; then
  sudo apt install -y terminator 2>/dev/null && echo "✅ Terminator installed" || echo "⚠️ Terminator install failed"
fi

# Warp terminal
if ! command -v warp-terminal >/dev/null 2>&1; then
  if wget https://app.warp.dev/download?package=deb -O warp.deb 2>/dev/null; then
    sudo apt install -y ./warp.deb 2>/dev/null && rm warp.deb && echo "✅ Warp installed" || echo "⚠️ Warp install failed"
  else
    echo "⚠️ Failed to download Warp"
  fi
fi


# =====================================================================
# 6. MEDIA & PRODUCTIVITY TOOLS
# =====================================================================

# VLC
sudo apt install -y vlc 2>/dev/null && echo "✅ VLC installed" || echo "⚠️ VLC install failed"

# AnyDesk
if ! command -v anydesk >/dev/null 2>&1; then
  echo "🖥️ Installing AnyDesk..."

  wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /usr/share/keyrings/anydesk.gpg 2>/dev/null

  echo "deb [signed-by=/usr/share/keyrings/anydesk.gpg] http://deb.anydesk.com/ all main" | \
    sudo tee /etc/apt/sources.list.d/anydesk.list > /dev/null

  if sudo apt update 2>/dev/null && sudo apt install -y anydesk 2>/dev/null; then
    echo "✅ AnyDesk installed"
  else
    echo "⚠️ AnyDesk install failed"
  fi
else
  echo "✅ AnyDesk already installed"
fi