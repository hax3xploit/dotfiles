#!/bin/bash
set -e

# ───[ Styling ]───
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[+] $1${NC}"; }
warn() { echo -e "${YELLOW}[-] $1${NC}"; }
error() { echo -e "${RED}[!] $1${NC}"; exit 1; }

# ───[ Installer Setup ]───
INSTALLER="apt-get"
if ! command -v $INSTALLER &>/dev/null; then
    error "This script only supports Debian/Ubuntu (apt-based) systems."
fi

if [ "$EUID" -ne 0 ]; then
    INSTALL="sudo $INSTALLER"
else
    INSTALL="$INSTALLER"
fi

# ───[ System Package Installation ]───
info "Installing dependencies (tmux, git, wget, curl, etc)..."
$INSTALL update -y
$INSTALL install -y \
    tmux wget git curl cmake pkg-config unzip \
    build-essential python3 libssl-dev \
    libfreetype6-dev libfontconfig1-dev \
    libxcb-xfixes0-dev libxkbcommon-dev \
    desktop-file-utils fonts-powerline \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    llvm libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    golang || error "Failed to install required packages."

# ───[ Install Rust & Cargo ]───
if ! command -v cargo &>/dev/null; then
    info "Rust not found. Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y || error "Rust installation failed."
    source "$HOME/.cargo/env"
else
    info "Rust already installed."
fi

# ───[ Install Alacritty ]───
if [ ! -d "$HOME/alacritty" ]; then
    info "Cloning Alacritty..."
    git clone https://github.com/alacritty/alacritty.git "$HOME/alacritty" || error "Alacritty clone failed."
else
    warn "Alacritty source already exists."
fi

if ! cd "$HOME/alacritty"; then
    error "Failed to change directory to $HOME/alacritty. Cannot build Alacritty."
fi

info "Building Alacritty..."
cargo build --release || warn "Alacritty build failed. Skipping installation steps."

sudo cp target/release/alacritty /usr/local/bin/ && info "Binary installed to /usr/local/bin." || warn "Failed to copy alacritty binary."
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg && info "Icon installed." || warn "Failed to install icon."
sudo desktop-file-install extra/linux/Alacritty.desktop && info "Desktop file installed." || warn "Failed to install desktop entry."
sudo update-desktop-database && info "Desktop database updated." || warn "Desktop DB update failed."
sudo tic -xe alacritty,alacritty-direct extra/alacritty.info && info "Termininfo compiled." || warn "Termininfo setup failed."

cd "$HOME"

# ───[ Install TPM ]───
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || error "TPM clone failed."
else
    info "TPM already exists."
fi

# ───[ Copy Dotfiles Locally ]───
info "Copying .tmux.conf from local directory..."
cp ./tmux.conf "$HOME/.tmux.conf" || error ".tmux.conf copy failed."

info "Copying alacritty.toml from local directory..."
mkdir -p "$HOME/.config/alacritty"
cp ./alacritty.toml "$HOME/.config/alacritty/alacritty.toml" || error "alacritty.toml copy failed."

# ───[ Optional: VPN Script Setup ]───
if [ -f ./vpn.sh ]; then
    sudo cp ./vpn.sh /opt/vpn.sh
    sudo chmod +x /opt/vpn.sh
    info "vpn.sh installed to /opt/vpn.sh"
else
    warn "vpn.sh not found in current directory (optional)."
fi

# ───[ Auto-Install Tmux Plugins ]───
info "Installing tmux plugins..."
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM plugin install failed."
tmux kill-session -t __noop >/dev/null 2>&1 || true

# ───[ Zsh Environment Setup ]───
info "✨ Installing Zsh and Oh My Zsh (optional)..."
$INSTALL install -y zsh || warn "Zsh installation failed."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "Oh My Zsh installation failed."
else
    info "Oh My Zsh already installed."
fi

info "🎨 Installing Powerlevel10k theme and Zsh plugins..."

export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Clone Powerlevel10k and essential plugins
mkdir -p "$ZSH_CUSTOM/plugins"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k" 2>/dev/null || info "Powerlevel10k already exists."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || info "zsh-autosuggestions already exists."
git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || info "zsh-syntax-highlighting already exists."
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" 2>/dev/null || info "fast-syntax-highlighting already exists."

# ───[ Copy multiline theme and shell extras from local directory ]───
if [ -f "./multiline.zsh-theme" ]; then
    cp "./multiline.zsh-theme" "$ZSH_CUSTOM/themes/multiline.zsh-theme"
    info "Custom multiline.zsh-theme installed to $ZSH_CUSTOM/themes."
else
    warn "multiline.zsh-theme not found in current directory."
fi

if [ -f "./.shell_extras.zsh" ]; then
    cp "./.shell_extras.zsh" "$HOME/.shell_extras.zsh"
    info ".shell_extras.zsh copied to home directory."
else
    warn ".shell_extras.zsh not found in current directory."
fi

# ───[ Replace .zshrc with local copy and back up existing ]───
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
    info "Backed up existing .zshrc to .zshrc.backup"
fi
cp ./.zshrc "$HOME/.zshrc" && info "Copied .zshrc from local directory."

# Append shell extras sourcing if not already present
if [ -f "$HOME/.shell_extras.zsh" ]; then
    if ! grep -q 'source ~/.shell_extras.zsh' "$HOME/.zshrc" 2>/dev/null; then
        echo 'source ~/.shell_extras.zsh' >> "$HOME/.zshrc"
        info "Appended source line to .zshrc"
    else
        info "source ~/.shell_extras.zsh already in .zshrc"
    fi
else
    warn "Skipped appending to .zshrc — shell extras not available."
fi

# Change default shell to zsh
if command -v zsh >/dev/null && [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)" || warn "Could not change default shell to zsh."
    info "Default shell set to zsh."
fi

# ───[ Install bat (batcat) ]───
if ! command -v batcat >/dev/null; then
    info "📦 Installing bat (batcat)..."
    $INSTALL install -y bat || warn "bat installation failed."
else
    info "batcat already installed."
fi

# ───[ Install pyenv ]───
if [ ! -d "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash || warn "pyenv installation failed."
else
    info "pyenv already installed."
fi

# ───[ Setup 24-bit Color Test Script ]───
info "Downloading 24-bit color test script for terminal support..."
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh -o 24-bit-color.sh && \
    bash 24-bit-color.sh && \
    info "True color test script executed." || \
    warn "Failed to run 24-bit color test."

# ───[ Install Nim ]───
install_nim() {
  if ! command -v nim &>/dev/null; then
    info "Installing Nim..."
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh || warn "Nim installation failed."
  else
    info "Nim is already installed."
  fi
}
install_nim

# ───[ Install Poetry ]───
install_poetry() {
  if ! command -v poetry &>/dev/null; then
    info "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 - || warn "Poetry installation failed."
  else
    info "Poetry is already installed."
  fi
}
install_poetry

# ───[ Install FZF ]───
install_fzf() {
  if [ ! -d "$HOME/.fzf" ]; then
    info "Cloning FZF..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install || warn "FZF install script failed."
  else
    info "FZF already exists. Running install script again to ensure setup..."
    ~/.fzf/install || warn "FZF install script failed."
  fi
}
install_fzf

# ───[ Done ]───
info "✅ Installation completed."
info "🧠 If not sourced automatically, run: source ~/.shell_extras.zsh"
