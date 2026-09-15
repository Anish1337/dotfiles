#
# ~/.bashrc
#

# Only continue for interactive shells
[[ $- != *i* ]] && return

# PATH
export PATH="/opt/shader-slang-bin/bin:$HOME/.local/bin:$PATH"

# Prompt
PS1='[\u@\h \W]\$ '

# Standard aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Custom shortcuts
alias c='clear'
alias shutdown='systemctl poweroff'
alias brc='nvim ~/.bashrc'
alias wifi='nmtui'
alias hypr='nvim ~/.config/hypr/hyprland.lua'
alias dots='cd ~/github/dotfiles'

# Git shortcuts
