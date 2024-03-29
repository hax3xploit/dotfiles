
##################################


##################################


function get_ip(){
   # It can be thm or htb IP
   tunnel_ip=`ifconfig tun0 2>/dev/null | grep netmask | awk '{print $2}'` 
   # Use eth0 as default IP,
   default_ip=`ifconfig eth0 2>/dev/null | grep netmask | awk '{print $2}'`
   if [[ $tunnel_ip == *"10."* ]]; then
      echo $tunnel_ip
   else
      echo $default_ip
   fi
}


############################

#alias sudo='sudo '

##################
#Genymotion
##################


alias adb_set_proxy='adb shell settings put global http_proxy $(get_ip):8082'
alias adb_unset_proxy='adb shell settings put global http_proxy :0'



##################
#   OpenVPNs
##################

alias htbon='sudo openvpn ~/.ovpnconfig/htb-sg.ovpn 1>/dev/null &' 
alias htbfort='sudo openvpn ~/.ovpnconfig/htb-fortress.ovpn 1>/dev/null &'
alias htbrel='sudo openvpn ~/.ovpnconfig/htb-release.ovpn 1>/dev/null &'
alias thm_vpn='sudo openvpn ~/.ovpnconfig/THM_vpn.ovpn 1>/dev/null &'

alias kvpn='sudo pkill openvpn'


#########################
#   Local HTTP
#########################

alias hostit='python3 -m http.server -d /opt/ 8000'


#######################

#######################

#######################

function mknote(){ 
  mkdir nmap gobuster loot logs exploits ssh-keys post-exploits 
}



#####################
#   Extract 
#####################

# Archives

function extract {
  if [ -z "$1" ]; then
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
  else
    if [ -f $1 ]; then
      case $1 in
        *.tar.bz2)   tar xvjf $1    ;;
        *.tar.gz)    tar xvzf $1    ;;
        *.tar.xz)    tar xvJf $1    ;;
        *.lzma)      unlzma $1      ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar x -ad $1 ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xvf $1     ;;
        *.tbz2)      tar xvjf $1    ;;
        *.tgz)       tar xvzf $1    ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *.xz)        unxz $1        ;;
        *.exe)       cabextract $1  ;;
        *)           echo "extract: '$1' - unknown archive method" ;;
      esac
    else
      echo "$1 - file does not exist"
    fi
  fi
}

alias extr='extract '
function extract_and_remove {
  extract $1
  rm -f $1
}

alias extrr='extract_and_remove '


#######################################

# Wget
alias wgetncc='wget --no-check-certificate'
alias wgetc='wget `getcb`'

function wget_archive_and_extract {
  URL=$1
  FILENAME=${URL##*/}
  wget $URL -O $FILENAME
  extract $FILENAME
  rmi $FILENAME
}

alias wgetae='wget_archive_and_extract '
alias wgetaec='wgetae getcb'


#########################################

# DNS
alias {hostname2ip,h2ip}='dig +short'


###########################################


alias cat='batcat'

# Tmux

alias tmux-new='tmux new -s'
alias tmux-kill='tmux kill-session -t'
alias tmux-attach='tmux attach -t'


# Utils
alias sitecopy='wget -k -K -E -r -l 10 -p -N -F -nH '
alias ytmp3='youtube-dl --extract-audio --audio-format mp3 '

alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:2.1.1'

alias nc='rlwrap nc'
alias recon-tainer="docker run -it --rm -v /root/results/:/root/results/ hax3xploit/recon-tainer:v1.0"

alias testssl='docker run --rm -ti  drwetter/testssl.sh'

alias mobsf='docker run -it --rm -p 8000:8000 opensecurity/mobile-security-framework-mobsf:latest'
