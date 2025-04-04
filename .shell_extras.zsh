# Load Aliases
[ -f "$HOME/aliases.sh" ] && source "$HOME/aliases.sh"

# Go Environment
export GOPATH=$HOME/go
export GOROOT=${GOROOT:-/usr/local/go}
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export GO111MODULE="off"

# Extra paths
export ZSH="$HOME/.zsh"
export PATH="$HOME/.fzf/bin:$HOME/.local/bin:$PATH"

# Zsh Auto-suggestions
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# Command-not-found hook
[ -f /etc/zsh_command_not_found ] && source /etc/zsh_command_not_found

# Tunnel IP Detection
function get_ip() {
    tunnel_ip=$(ifconfig tun0 2>/dev/null | awk '/inet / {print $2}')
    default_ip=$(ifconfig eth0 2>/dev/null | awk '/inet / {print $2}')
    [[ $tunnel_ip == 10.* ]] && echo "$tunnel_ip" || echo "$default_ip"
}

# VPN Aliases
alias htbon='sudo openvpn ~/.ovpnconfig/htb-sg.ovpn &>/dev/null &'
alias htbfort='sudo openvpn ~/.ovpnconfig/htb-fortress.ovpn &>/dev/null &'
alias htbrel='sudo openvpn ~/.ovpnconfig/htb-release.ovpn &>/dev/null &'
alias thm_vpn='sudo openvpn ~/.ovpnconfig/THM_vpn.ovpn &>/dev/null &'
alias kvpn='sudo pkill openvpn'

# Tools
alias apk-tool='bash ~/apk.sh/apk.sh'
alias hostit='python3 -m http.server -d /opt/ 8000'
alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:2.1.1'
alias recon-tainer='docker run -it --rm -v /root/results/:/root/results/ hax3xploit/recon-tainer:v1.0'
alias testssl='docker run --rm -ti drwetter/testssl.sh'
alias mobsf='docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest'

# ADB Proxy
alias adb_set_proxy='adb shell settings put global http_proxy $(get_ip):8082'
alias adb_unset_proxy='adb shell settings put global http_proxy :0'

# Extraction Functions
function extract {
    [[ -z $1 ]] && echo "Usage: extract <file>" && return
    [[ ! -f $1 ]] && echo "$1 - file does not exist" && return
    case $1 in
        *.tar.bz2) tar xvjf $1 ;;
        *.tar.gz)  tar xvzf $1 ;;
        *.tar.xz)  tar xvJf $1 ;;
        *.lzma)    unlzma $1 ;;
        *.bz2)     bunzip2 $1 ;;
        *.rar)     unrar x -ad $1 ;;
        *.gz)      gunzip $1 ;;
        *.tar)     tar xvf $1 ;;
        *.tbz2)    tar xvjf $1 ;;
        *.tgz)     tar xvzf $1 ;;
        *.zip)     unzip $1 ;;
        *.Z)       uncompress $1 ;;
        *.7z)      7z x $1 ;;
        *.xz)      unxz $1 ;;
        *.exe)     cabextract $1 ;;
        *)         echo "extract: '$1' - unknown archive method" ;;
    esac
}
alias extr='extract'
alias extrr='extract_and_remove'
function extract_and_remove() { extract $1 && rm -f $1; }

# Note-taking Folder Setup
mknote() {
    mkdir -p nmap gobuster loot logs exploits ssh-keys post-exploits
}

# Download + extract + delete archive
function wget_archive_and_extract {
    URL=$1
    FILENAME=${URL##*/}
    wget "$URL" -O "$FILENAME" && extract "$FILENAME" && rm -f "$FILENAME"
}
alias wgetae='wget_archive_and_extract'

# DNS
alias h2ip='dig +short'

# Colorful Tools
alias cat='batcat'
alias nc='rlwrap nc'

# Tmux helpers
alias tmux-new='tmux new -s'
alias tmux-kill='tmux kill-session -t'
alias tmux-attach='tmux attach -t'

# Misc Tools
alias sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH'
alias ytmp3='youtube-dl --extract-audio --audio-format mp3'

# FZF Integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
