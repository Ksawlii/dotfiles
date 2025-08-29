#!/bin/bash
# Oh My Zsh
plugins=(
    "git"
    "zsh-completions"
    "zsh-history-substring-search"
    "zsh-syntax-highlighting"
)

source "$ZSH/oh-my-zsh.sh"

# Oh My Posh
eval "$(oh-my-posh init zsh --config "$HOME/.config/ohmyposh/EDM115-newline.omp.json")"
