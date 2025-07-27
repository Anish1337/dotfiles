#
# ~/.bashrc
#

# neofetch
neofetch

# Custom shortcuts
alias c='clear'
alias shutdown='systemctl poweroff'
alias bash='nvim ~/.bashrc'
alias wifi='nmtui'
alias hypr='nvim ~/.config/hypr/hyprland.conf'
alias practice='cd ~/github/practice'
alias dots='cd ~/github/dotfiles'

# git shortcuts

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
