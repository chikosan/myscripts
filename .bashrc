# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ls='ls -lh'

# My shorts
alias shservices='systemctl list-unit-files --type service | grep "enabled \|disabled"'
alias myip='curl -s ipinfo.io | jq -r ".ip"'


# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
