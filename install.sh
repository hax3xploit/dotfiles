#!/bin/bash

NOCOLOR='\033[0m'
BOLD='\e[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

bar="---------------------------------------"
# /bin/zsh install.sh
echo -e "$bar\n\t ${RED}EZ Tmux by @hax_3xploit ${NOCOLOR} \n$bar"

is_app_installed() {
    type "$1" &>/dev/null
}

if ! is_app_installed tmux; then
    printf "WARNING: \"tmux\" command is not found.\n"
fi

echo -e "${RED} Installing all dependencies ${NOCOLOR} \n"

if sudo apt-get install tmux wget git -y 2>/dev/null; then
    echo -e "$bar\n\t ${LIGHTPURPLE} Dependencies Installed ${NOCOLOR} \n$bar"
    echo -e "${GREEN}Tmux ✔️ ${NOCOLOR} \n"
    sleep 1s
    echo -e "${GREEN}Wget ✔️ ${NOCOLOR} \n"
    sleep 1s
    echo -e "${GREEN}Git  ✔️ ${NOCOLOR} \n"
else
    echo -e "${RED}Failed to install dependencies.${NOCOLOR}"
    exit 1
fi

# Remove existing vpn.sh if present
if sudo [ -f "/opt/vpn.sh" ]; then
    echo -e "$bar\n\t ${LIGHTPURPLE} Removing existing vpn.sh ${NOCOLOR}\n$bar"
    sudo rm /opt/vpn.sh
fi

echo -e "$bar\n\t ${LIGHTPURPLE} Install plugins ${NOCOLOR}\n$bar"

# Check if TPM directory already exists
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${ORANGE}TPM directory already exists. Skipping cloning.${NOCOLOR}"
else
    if sudo git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm 2>/dev/null; then
        echo -e "${GREEN}Plugins cloned successfully.${NOCOLOR}"
    else
        echo -e "${RED}Failed to clone plugins.${NOCOLOR}"
        exit 1
    fi
fi

if sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/vpn.sh -O /opt/vpn.sh 2>/dev/null && sudo chmod +x /opt/vpn.sh; then
    echo -e "${GREEN}vpn.sh script downloaded successfully.${NOCOLOR}"
else
    echo -e "${RED}Failed to download vpn.sh script.${NOCOLOR}"
    exit 1
fi

# Download .tmux.conf if not present
if [ ! -f "$HOME/.tmux.conf" ]; then
    echo -e "$bar\n\t ${LIGHTPURPLE} Downloading .tmux.conf ${NOCOLOR}\n$bar"
    sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/.tmux.conf -O $HOME/.tmux.conf 2>/dev/null
    echo -e "${GREEN}.tmux.conf downloaded successfully.${NOCOLOR}"
else
    echo -e "${ORANGE}.tmux.conf already exists. Skipping download.${NOCOLOR}"
fi

# Remove existing alacritty.toml if present
if sudo [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
    echo -e "$bar\n\t ${LIGHTPURPLE} Removing existing alacritty.toml ${NOCOLOR}\n$bar"
    sudo rm $HOME/.config/alacritty/alacritty.toml
fi

# Check if Alacritty is installed
if ! is_app_installed alacritty; then
    echo -e "${ORANGE}Alacritty is not installed. Skipping the download of alacritty.toml.${NOCOLOR}"
else
    echo -e "$bar\n\t ${LIGHTPURPLE} Downloading alacritty.toml ${NOCOLOR}\n$bar"

    sudo mkdir -p ~/.config/alacritty &&
    sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/alacritty.toml -O ~/.config/alacritty/alacritty.toml 2>/dev/null &&
    echo -e "${GREEN}Alacritty configuration downloaded successfully.${NOCOLOR}"
fi

# Download aliases.sh to ~/.config/
if sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/aliases.sh -O ~/.config/aliases.sh 2>/dev/null && sudo chmod +x ~/.config/aliases.sh; then
    echo "Aliases script downloaded successfully."
else
    echo "Failed to download aliases script."
    exit 1
fi

# Check the current shell
SHELL_TYPE=$(basename "$SHELL")

# Source aliases.sh in the appropriate shell configuration file
if [ "$SHELL_TYPE" = "bash" ]; then
    # Add source command to ~/.bashrc
    if ! grep -q "source ~/.config/aliases.sh" ~/.bashrc; then
        echo "source ~/.config/aliases.sh" >> ~/.bashrc
        echo "Aliases sourced in ~/.bashrc"
    else
        echo "Aliases already sourced in ~/.bashrc"
    fi
    source ~/.bashrc
elif [ "$SHELL_TYPE" = "zsh" ]; then
    # Add source command to ~/.zshrc
    if ! grep -q "source ~/.config/aliases.sh" ~/.zshrc; then
        echo "source ~/.config/aliases.sh" >> ~/.zshrc
        echo "Aliases sourced in ~/.zshrc"
    else
        echo "Aliases already sourced in ~/.zshrc"
    fi
    
    # Check if the current shell is Zsh
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
    # If not, print an error message and exit
    echo "Error: Oh My Zsh can't be loaded from a non-Zsh shell. You need to run zsh instead."
    exit 1
fi
    source ~/.zshrc
else
    echo "Unsupported shell: $SHELL_TYPE"
    exit 1
fi

tmux new -d -s __noop >/dev/null 2>&1 || true 
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
$HOME/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

printf "OK: Completed\n"
tmux source $HOME/.tmux.conf
