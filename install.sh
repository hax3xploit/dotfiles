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

cd "$HOME/alacritty"
info "Building Alacritty..."
cargo build --release || error "Alacritty build failed."
sudo cp target/release/alacritty /usr/local/bin/
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database || warn "Desktop DB update failed."
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info || warn "Termininfo setup failed."

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

info "NOTE: To enable your custom configs, add this line to your .zshrc manually:"
echo 'source ~/.shell_extras.zsh'

# ──────────────[ Optional: VPN Script Setup ]──────────────
if wget -q -O /opt/vpn.sh https://raw.githubusercontent.com/hax3xploit/dotfiles/master/vpn.sh; then
    chmod +x /opt/vpn.sh
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

# ──────────────[ Done ]──────────────
info "✅ Installation completed."
info "🧠 Remember to run: source ~/.shell_extras.zsh OR add it to your .zshrc"
