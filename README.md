# 🚀 Ultimate Unified Dev Setup

A single, robust script to automate the setup of a professional development environment on Ubuntu/Debian-based systems. This setup is designed for **maximum productivity**, **aesthetic excellence**, and **idempotent stability**.

---

## 🛠️ Feature Overview

### 🎨 Shell & Aesthetic
- **Zsh Default**: Oh My Zsh framework with **Powerlevel10k** theme.
- **Smart Completion**: Autosuggestions and Syntax Highlighting.
- **Modern CLI**: `eza` (ls), `bat` (cat), `zoxide` (z), `rg` (grep), `fd` (find).
- **Fonts**: JetBrains Mono Nerd Font & Font Awesome for rich icons.
- **Shell Enhancements**: FZF integration, history search, and smart completions.

### 💻 Developer Ecosystem
- **Runtimes**: `pyenv` (Python) and `nvm` (Node.js/npm/pnpm).
- **Virtualization**: **Docker** (Engine + Compose) with GUI support.
- **IDEs (AI-Native)**: Cursor, Windsurf, Antigravity, Qoder, VS Code, and **JetBrains Toolbox**.

### 🌐 Apps & Utilities
- **Browsers**: Chrome, Brave.
- **API Testing**: Postman, Insomnia (Redis Insight).
- **Communication**: Slack, AnyDesk.
- **Tools**: Terminator, Warp Terminal.
- **Media**: VLC Media Player.
- **System**: GNOME Tweaks, Extension Manager, CPU/Network/Memory monitoring extensions.

---

## 🚀 Getting Started

### Prerequisites
- Ubuntu/Debian-based Linux distribution (22.04 recommended)
- Internet connection
- sudo privileges

### Installation Steps

1. **Clone or Download**:
   ```bash
   cd /path/to/linux-setup
   ```

2. **Make Scripts Executable**:
   ```bash
   chmod +x base.sh setup.sh
   ```

3. **Run Base Setup First** (installs system dependencies and Zsh):
   ```bash
   ./base.sh
   ```

4. **Run Main Setup** (installs IDEs, browsers, and applications):
   ```bash
   ./setup.sh
   ```

---

## 🏁 Post-Installation Actions

> [!IMPORTANT]
> Some changes require a shell restart or system logout to take effect.

1. **Apply Zsh Changes**: Run `exec zsh` or restart your terminal.
2. **Setup P10K**: The Powerlevel10k wizard should start automatically. Run `p10k configure` if needed.
3. **Docker Access**: Log out and log back in to refresh group permissions, or run:
   ```bash
   newgrp docker
   ```
4. **Enable GNOME Extensions**: Open **Extension Manager** and enable desired monitoring/shell extensions.
5. **Set Default Shell** (if not already): 
   ```bash
   chsh -s $(which zsh)
   ```

---

## 🔍 Verification & Troubleshooting

### Verification Commands
| Tool | Command to Verify | Expected Output |
| :--- | :--- | :--- |
| **Zsh** | `zsh --version` | Zsh version number |
| **Oh My Zsh** | `echo $ZSH` | Should show `~/.oh-my-zsh` |
| **Node.js** | `node -v` | Node.js version |
| **Python** | `python --version` or `pyenv version` | Python version |
| **Docker** | `docker ps` | Empty container list (no error) |
| **Docker Compose** | `docker compose version` | Compose version |
| **Modern LS** | `ls` | Files with icons and colors |
| **Modern Cat** | `cat README.md` | Syntax-highlighted output |
| **Eza** | `eza --version` | Eza version |
| **Bat** | `bat --version` | Bat version |

### Troubleshooting Tips
- **Docker**: If it fails to start, ensure virtualization (VT-x/AMD-V) is enabled in your BIOS.
- **GNOME Shell**: If extensions aren't appearing, restart the shell (`Alt+F2`, type `r`, then `Enter` - on X11 only).
- **NVM/Pyenv**: If commands are "not found" immediately after install, check your `~/.zshrc` for the initialization blocks.
- **Zsh Not Default**: Run `chsh -s $(which zsh)` and restart terminal.
- **PATH Issues**: Ensure `~/.local/bin` is in your PATH (check with `echo $PATH`).
- **Powerlevel10K Icons**: Install [Nerd Fonts](https://www.nerdfonts.com/) if icons appear as squares.

---

## ⚡ Fast-Path Shortcuts (Zsh Aliases)

The setup pre-configures several productivity-boosting aliases in your `~/.zshrc`:

### 📂 File Management (Modern Replacements)
| Alias | Tool | Description |
| :--- | :--- | :--- |
| `ls` | `eza --icons --group-directories-first` | List files with icons and colors |
| `ll` | `eza -alF --icons` | Detailed list with hidden files |
| `la` | `eza -a --icons` | Show all files including hidden |
| `l` | `eza -F --icons` | Quick list view |
| `tree`| `eza --tree --icons` | Visual directory tree |
| `cat` | `bat` / `batcat` | View file with syntax highlighting |
| `z <dir>` | `zoxide` | Smart directory jumping |

### 🐙 Git & Development
| Alias | Command | Description |
| :--- | :--- | :--- |
| `gs` | `git status` | Show git status |
| `gd` | `git diff` | Show changes |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `pi` | `pnpm install` | Install pnpm dependencies |
| `pd` | `pnpm dev` | Run dev server |

### 🔍 Search & Navigation
| Alias | Tool | Description |
| :--- | :--- | :--- |
| `fd` | `fd-find` | Fast file finder |
| `rg` | `ripgrep` | Fast grep alternative |
| `fzf` | FZF | Fuzzy finder integration |

---

## 📂 Project Structure

```
linux-setup/
├── base.sh           # Base system setup (dependencies, Zsh, shell config)
├── setup.sh          # Application installer (IDEs, browsers, tools)
├── README.md         # This comprehensive guide
└── ~/Apps/           # Created during install (for AppImages)
```

### Script Responsibilities

**base.sh** (Run First):
- Updates system packages
- Installs base dependencies (build tools, fonts, utilities)
- Installs eza, bat, zoxide, ripgrep, fd
- Configures Zsh with Oh My Zsh and Powerlevel10k
- Sets up shell plugins and aliases
- Installs GNOME tools

**setup.sh** (Run Second):
- Installs pyenv and nvm for runtime management
- Sets up Docker with Compose
- Installs browsers (Chrome, Brave)
- Installs IDEs (VS Code, Antigravity, Qoder)
- Adds API tools (Postman, Redis Insight)
- Installs communication apps (Slack, AnyDesk)
- Adds terminals (Terminator, Warp)
- Installs media tools (VLC)

---

## 🧹 Maintenance

### Update Installed Packages
```bash
sudo apt update && sudo apt upgrade -y
```

### Update Pyenv/Nvm Packages
```bash
pyenv update
nvm update
```

### Re-run Setup
Both scripts are idempotent - safe to re-run to fix issues or add missing components.

---

## 📝 Notes

- **Idempotent Design**: All scripts can be safely re-run without breaking existing installations
- **Non-Destructive**: Scripts check for existing installations before attempting to install
- **Error Tolerance**: Scripts continue even if individual package installations fail
- **Custom Configuration**: Your `~/.zshrc` is appended to, not overwritten

---
*Created with ❤️ for a professional Linux developer setup.*


<!-- chsh -s $(which zsh)

cd /opt/
> sudo tar -xvzf ~/Downloads/jetbrains-toolbox-3.4.1.78303.tar.gz 
> sudo mv jetbrains-toolbox-3.4.1.78303 jetbrains
jetbrains/bin/jetbrains-toolbox  -->