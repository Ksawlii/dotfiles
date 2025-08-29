#!/bin/bash
# Android
alias sync="repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --jobs-network=4"
alias b="make bacon -j$(nproc --all)"

# Basic
alias l="ls"
alias la="ls -a"
alias s="$ROOT"
alias scp="$ROOT cp -r"
alias catboys="cat"
alias rm="$ROOT rm -rf"
alias v="$EDITOR"

# Git
alias gcl="git clone -j$(nproc --all)"
alias gad="git add"
alias gcm="git commit -s -m"
alias gra="git remote add"
alias gpu="git push -u"
alias gin="git init"
alias gbr="git branch"
alias gpl="git pull -j$(nproc --all)"
alias gru="git remote update"
alias gcp="git cherry-pick -s"
alias gccp="git cherry-pick --continue"
alias gcs="git cherry-pick --skip"
alias gst="git status"
alias grm="git remote remove"
alias gck="git checkout"
alias grv="git revert -s"
alias grc="git revert --continue"
alias grs="git restore --staged"
alias grb="git revert --abort"
alias grn="git revert --no-edit -S -s"
alias gco="git commit -s"
alias gca="git commit -s --amend"
alias gmr="git merge -S --signoff --log"
alias gms="git merge --skip"
alias gma="git merge --abort"
alias gre="git restore"
alias glo="git --no-pager log --oneline"

# Misc
alias solvo-vid="timg -V \"$HOME/.config/zsh/vids/solvo.webm\""

# Package Manager
if grep -qi "gentoo" "/etc/os-release"; then
    alias ins="$ROOT emerge -navq"
    alias sup="$ROOT emerge --sync && $ROOT emerge -avq --changed-use --newuse --update --deep @world"
    alias up="$ROOT emerge -avq --changed-use --newuse --update --deep @world"
    alias mc="$ROOT $EDITOR /etc/portage/make.conf"
elif grep -qi "arch" "/etc/os-release"; then
    alias ins="$ROOT pacman -S --needed --noconfirm"
    alias up="$ROOT pacman -Syyuu --needed --noconfirm"
fi

# Zsh shortcuts
alias zshrc="$EDITOR $HOME/.zshrc"
alias zsh="source $HOME/.zshrc"
