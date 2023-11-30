#-----------------------------------------------------
# ALIASES
# ----------------------------------------------------
alias c='clear'
alias nf='neofetch'
alias pf='pfetch'
alias shutdown='systemctl poweroff'
alias v='nvim'
alias ts='~/dotfiles/scripts/snapshot.sh'
alias matrix='cmatrix'
alias wifi='nmtui'

alias uk='cp ~/.config/kitty/kitty.conf ~/GitHub/Personal/dotfiles/kitty/'
alias ub='cp ~/.bashrc ~/GitHub/Personal/dotfiles/bashrc/'
alias bash='nvim ~/.bashrc'
alias code='cd ~/GitHub/Personal/practice/Leetcode/Arrays_Strings/'
alias dot='cd ~/GitHub/Personal/dotfiles/'
alias g='cd ~/GitHub/Personal/'

# -----------------------------------------------------
# GIT
# -----------------------------------------------------
alias gs="git status"
alias ga="git add"
alias gc="git commit -am"
alias gp="git push"
alias gpl="git pull"

# -----------------------------------------------------
# EDIT NOTES
# -----------------------------------------------------
alias notes='vim ~/notes.txt'


# -----------------------------------------------------
# START STARSHIP
# -----------------------------------------------------
eval "$(starship init bash)"

# -----------------------------------------------------
# PYWAL
# -----------------------------------------------------
# cat ~/.cache/wal/sequences

# -----------------------------------------------------
# PFETCH
# -----------------------------------------------------
echo ""
pfetch

#
# Git shortcut
#
#
function submit() {
    git add .
    git commit -a -m "$1"
    git push
}

export PATH=/home/anish/.local/bin:$PATH
