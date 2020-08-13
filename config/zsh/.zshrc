# General settings
autoload -U colors && colors
setopt HIST_IGNORE_SPACE
setopt incappendhistory
setopt sharehistory

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit

# Include hidden files in completions
_comp_options+=(globdots)

# Set cache directory
ZSH_CACHE_DIR="$HOME/.cache/zsh"

# Use vi keybindings
bindkey -v

# Use vi keys in completion menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# History stuff
HISTFILE=$ZDOTDIR/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# Start starship
eval $(starship init zsh)

# Load extra.zshrc
source $ZDOTDIR/extra.zshrc
