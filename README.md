# Dotfiles

This repository contains **my personal environment setup**, configurations, and dotfiles. It’s tailored for my workflow and includes:

* Zsh with Powerlevel10k and plugin setup
* Tmux with TPM and custom config
* Alacritty with custom theme and 24-bit color support
* Developer toolchain: Python, Rust, Go, Nim, Poetry, FZF, etc.
* Custom shell aliases and utility scripts

---

## 🔧 Setup Instructions (for my own machines)

### 1. Clone the Repo

```bash
git clone https://github.com/hax3xploit/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run the Installer

```bash
chmod +x install.sh
./install.sh
```

This will:

* Install system packages & dev tools
* Setup Zsh, Oh My Zsh, Powerlevel10k
* Install and configure Tmux, Alacritty, and plugins
* Place all my configs in the right place
* Copy shell extras, VPN script, themes, etc.
* Install toolchains for Nim, Go, Poetry, Rust, etc.

---

## 📂 Config Files

* `.zshrc` → Shell config with plugins
* `.shell_extras.zsh` → My aliases and functions
* `.tmux.conf` → Tmux keybindings and plugins
* `alacritty.toml` → Terminal theme/colors
* `vpn.sh` → VPN utility script (optional)
* `multiline.zsh-theme` → Zsh prompt theme

---

## ✅ Tools Installed

These are installed if missing:

* **Zsh + Oh My Zsh + Powerlevel10k**
* **Tmux + TPM**
* **Alacritty**
* **Rust (via rustup)**
* **Go (via apt)**
* **Python + pyenv**
* **Poetry (via official script)**
* **Nim (via choosenim)**
* **FZF**

Paths are managed to match my system layout (`~/.local/bin`, `~/go/bin`, `~/.poetry/bin`, etc).

---

## 🎨 Fonts & Terminal

* Requires a terminal that supports **Powerline fonts** (e.g., Meslo Nerd Font)
* Powerlevel10k prompt and 24-bit color supported
* To reconfigure prompt: `p10k configure`

---

## 🎨 Color Test (True Color)

To verify terminal supports true color and italics (for Tmux/Vim/Alacritty):

```bash
bash 24-bit-color.sh
```

---

## 🧠 Notes to Self

* Run `source ~/.zshrc` after install
* If VPN script is missing, drop `vpn.sh` manually
* This setup is optimized for **Debian/Ubuntu systems**

---

## © Personal Use

This is **my personal dotfile setup** — not intended as a public framework.
Feel free to peek if you're curious, but it’s not designed for others.
