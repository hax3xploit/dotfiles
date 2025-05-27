#!/bin/bash
set -e

# ──────────────[ Styling ]──────────────
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[+] $1${NC}"; }
warn() { echo -e "${YELLOW}[-] $1${NC}"; }
error() { echo -e "${RED}[!] $1${NC}"; exit 1; }

# ──────────────[ Installer Setup ]──────────────
INSTALLER="apt-get"
if ! command -v $INSTALLER &>/dev/null; then
    error "This script only supports Debian/Ubuntu (apt-based) systems."
fi

if [ "$EUID" -ne 0 ]; then
    INSTALL="sudo $INSTALLER"
else
    INSTALL="$INSTALLER"
fi

# ──────────────[ System Package Installation ]──────────────
info "Installing dependencies (tmux, git, wget, curl, etc)..."
$INSTALL update -y
$INSTALL install -y \
    tmux wget git curl cmake pkg-config unzip \
    build-essential python3 libssl-dev \
    libfreetype6-dev libfontconfig1-dev \
    libxcb-xfixes0-dev libxkbcommon-dev || error "Failed to install required packages."

# ──────────────[ Install Rust & Cargo ]──────────────
if ! command -v cargo &>/dev/null; then
    info "Rust not found. Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y || error "Rust installation failed."
    source "$HOME/.cargo/env"
else
    info "Rust already installed."
fi

# ──────────────[ Install Alacritty ]──────────────
if [ ! -d "$HOME/alacritty" ]; then
    info "Cloning Alacritty..."
    git clone https://github.com/alacritty/alacritty.git "$HOME/alacritty" || error "Alacritty clone failed."
else
    warn "Alacritty source already exists."
fi

if cd "$HOME/alacritty"; then
    info "Building Alacritty..."
else
    warn "Failed to change directory to \$HOME/alacritty. Skipping Alacritty build."
    cd "$HOME"
fi

if cargo build --release; then
    info "Alacritty built successfully."
else
    warn "Alacritty build failed. Skipping installation steps."
    cd "$HOME"
fi

if sudo cp target/release/alacritty /usr/local/bin/; then
    info "Binary installed to /usr/local/bin."
else
    warn "Failed to copy alacritty binary."
fi

if sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg; then
    info "Icon installed."
else
    warn "Failed to install icon."
fi

if sudo desktop-file-install extra/linux/Alacritty.desktop; then
    info "Desktop file installed."
else
    warn "Failed to install desktop entry."
fi

if sudo update-desktop-database; then
    info "Desktop database updated."
else
    warn "Desktop DB update failed."
fi

if sudo tic -xe alacritty,alacritty-direct extra/alacritty.info; then
    info "Termininfo compiled."
else
    warn "Termininfo setup failed."
fi

cd "$HOME"

# ──────────────[ Install TPM ]──────────────
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || error "TPM clone failed."
else
    info "TPM already exists."
fi

# ──────────────[ Download Dotfiles ]──────────────
info "Fetching .tmux.conf..."
wget -q -O "$HOME/.tmux.conf" https://raw.githubusercontent.com/hax3xploit/dotfiles/master/.tmux.conf || error "tmux.conf fetch failed."

info "Fetching alacritty.toml..."
mkdir -p "$HOME/.config/alacritty"
wget -q -O "$HOME/.config/alacritty/alacritty.toml" https://raw.githubusercontent.com/hax3xploit/dotfiles/master/alacritty.toml || error "alacritty.toml fetch failed."

info "Fetching aliases.sh..."
wget -q -O "$HOME/aliases.sh" https://raw.githubusercontent.com/hax3xploit/dotfiles/master/aliases.sh || error "aliases.sh fetch failed."

info "Fetching shell extras (~/.shell_extras.zsh)..."
wget -q -O "$HOME/.shell_extras.zsh" https://raw.githubusercontent.com/hax3xploit/dotfiles/master/.shell_extras.zsh || warn "shell_extras.zsh fetch failed."

# ──────────────[ Source .shell_extras.zsh into .zshrc ]──────────────
if [ -f "$HOME/.shell_extras.zsh" ]; then
    if ! grep -q 'source ~/.shell_extras.zsh' "$HOME/.zshrc" 2>/dev/null; then
        echo 'source ~/.shell_extras.zsh' >> "$HOME/.zshrc"
        info "Appended source line to .zshrc"
    else
        info "source ~/.shell_extras.zsh already in .zshrc"
    fi
else
    warn "Skipped appending to .zshrc — shell extras not downloaded."
fi

# ──────────────[ Optional: VPN Script Setup ]──────────────
if sudo wget -q -O /opt/vpn.sh https://raw.githubusercontent.com/hax3xploit/dotfiles/master/vpn.sh; then
    sudo chmod +x /opt/vpn.sh
    info "vpn.sh installed to /opt/vpn.sh"
else
    warn "vpn.sh fetch failed (optional)."
fi

# ──────────────[ Auto-Install Tmux Plugins ]──────────────
info "Installing tmux plugins..."
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM plugin install failed."
tmux kill-session -t __noop >/dev/null 2>&1 || true

# ──────────────[ Zsh Environment Setup ]──────────────
info "✨ Installing Zsh and Oh My Zsh (optional)..."
$INSTALL install -y zsh || warn "Zsh installation failed."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "Oh My Zsh installation failed."
else
    info "Oh My Zsh already installed."
fi

info "🎨 Installing Powerlevel10k theme and Zsh plugins..."

export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k" || warn "Powerlevel10k clone failed."
else
    info "Powerlevel10k already exists."
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" || warn "zsh-autosuggestions clone failed."
else
    info "zsh-autosuggestions already exists."
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || warn "zsh-syntax-highlighting clone failed."
else
    info "zsh-syntax-highlighting already exists."
fi


# ──────────────[ Configure .zshrc for Powerlevel10k and Plugins ]──────────────
if [ -f "$HOME/.zshrc" ]; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    
    if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' "$HOME/.zshrc"
        info "Updated .zshrc plugins with zsh-autosuggestions and zsh-syntax-highlighting."
    else
        info "zsh plugins already set in .zshrc."
    fi
else
    warn ".zshrc not found — plugin config skipped."
fi


info "📦 Installing bat (batcat)..."
$INSTALL install -y bat || warn "bat installation failed."


# ──────────────[ Done ]──────────────
info "✅ Installation completed."
info "🧠 If not sourced automatically, run: source ~/.shell_extras.zsh"
