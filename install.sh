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

echo "$bar\n\t ${RED}EZ Tmux by @hax_3xploit ${NOCOLOR} \n$bar"

clear
echo "$bar\n\t ${RED}EZ Tmux by @hax_3xploit ${NOCOLOR} \n$bar"

is_app_installed() {
    type "$1" &>/dev/null
}

if ! is_app_installed tmux; then
    printf "WARNING: \"tmux\" command is not found.\n"
fi

echo "${RED} Installing all dependencies ${NOCOLOR} \n"

if sudo apt-get install tmux wget git -y 2>/dev/null; then
    echo "$bar\n\t ${LIGHTPURPLE} Dependencies Installed ${NOCOLOR} \n$bar"
    echo "${GREEN}Tmux ✔️ ${NOCOLOR} \n"
    sleep 1s
    echo "${GREEN}Wget ✔️ ${NOCOLOR} \n"
    sleep 1s
    echo "${GREEN}Git  ✔️ ${NOCOLOR} \n"
else
    echo "${RED}Failed to install dependencies.${NOCOLOR}"
    exit 1
fi

# Remove existing vpn.sh if present
if sudo [ -f "/opt/vpn.sh" ]; then
    echo "$bar\n\t ${LIGHTPURPLE} Removing existing vpn.sh ${NOCOLOR}\n$bar"
    sudo rm /opt/vpn.sh
fi

echo "$bar\n\t ${LIGHTPURPLE} Install plugins ${NOCOLOR}\n$bar"

# Check if TPM directory already exists
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "${ORANGE}TPM directory already exists. Skipping cloning.${NOCOLOR}"
else
    if sudo git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm 2>/dev/null; then
        echo "${GREEN}Plugins cloned successfully.${NOCOLOR}"
    else
        echo "${RED}Failed to clone plugins.${NOCOLOR}"
        exit 1
    fi
fi

if sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/vpn.sh -O /opt/vpn.sh 2>/dev/null; then
    echo "${GREEN}vpn.sh script downloaded successfully.${NOCOLOR}"
else
    echo "${RED}Failed to download vpn.sh script.${NOCOLOR}"
    exit 1
fi

# Download .tmux.conf if not present
if [ ! -f "$HOME/.tmux.conf" ]; then
    echo "$bar\n\t ${LIGHTPURPLE} Downloading .tmux.conf ${NOCOLOR}\n$bar"
    sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/.tmux.conf -O $HOME/.tmux.conf 2>/dev/null
    echo "${GREEN}.tmux.conf downloaded successfully.${NOCOLOR}"
else
    echo "${ORANGE}.tmux.conf already exists. Skipping download.${NOCOLOR}"
fi

# Remove existing alacritty.toml if present
if sudo [ -f "$HOME/.config/alacritty/alacritty.toml" ]; then
    echo "$bar\n\t ${LIGHTPURPLE} Removing existing alacritty.toml ${NOCOLOR}\n$bar"
    sudo rm $HOME/.config/alacritty/alacritty.toml
fi

# Check if Alacritty is installed
if ! is_app_installed alacritty; then
    echo "${ORANGE}Alacritty is not installed. Skipping the download of alacritty.toml.${NOCOLOR}"
else
    echo "$bar\n\t ${LIGHTPURPLE} Downloading alacritty.toml ${NOCOLOR}\n$bar"

    sudo mkdir -p ~/.config/alacritty &&
    sudo wget https://raw.githubusercontent.com/hax3xploit/dotfiles/master/alacritty.toml -O ~/.config/alacritty/alacritty.toml 2>/dev/null &&
    echo "${GREEN}Alacritty configuration downloaded successfully.${NOCOLOR}"
fi

tmux new -d -s __noop >/dev/null 2>&1 || true 
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "~/.tmux/plugins"
$HOME/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

printf "OK: Completed\n"
tmux source $HOME/.tmux.conf
