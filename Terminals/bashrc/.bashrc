#-----------------------------------------------------
# BASIC COMMANDS
# ----------------------------------------------------
alias c='clear'
alias nf='neofetch'
alias pf='pfetch'
alias shutdown='systemctl poweroff'
alias v='nvim'
alias ts='~/dotfiles/scripts/snapshot.sh'
alias matrix='cmatrix'
alias wifi='nmtui'

#
# UPDATING GITHUB FILES
#
alias uk='cp ~/.config/kitty/kitty.conf ~/GitHub/Personal/dotfiles/Terminals/kitty/'
alias ub='cp ~/.bashrc ~/GitHub/Personal/dotfiles/Terminals/bashrc/'


#
# EDIT DOTFILES
#
alias bash='nvim ~/.bashrc'

#
# FILE NAVIGATION
#
alias code='cd ~/GitHub/Personal/practice/Leetcode/Arrays_Strings/'
alias dot='cd ~/GitHub/Personal/dotfiles/'
alias g='cd ~/GitHub/Personal/'

# -----------------------------------------------------
# GITHUB
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
# PFETCH
# -----------------------------------------------------
echo ""
neofetch --ascii ~/.config/neofetch/arch

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
