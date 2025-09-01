#!/bin/bash
#
# Copyright (C) 2025 Majaahh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

set -e

if [[ "$PARENT_NAME" != "install.sh" ]]; then
    echo "Please use the install.sh script in the root dir."
    exit 1
fi

source "$SRC_DIR/scripts/utils/common_utils.sh" || exit 1
source "$SRC_DIR/scripts/utils/log_utils.sh" || exit 1

# [
GET_OMZ()
{
    LOG_STEP_IN "- Installing Oh My Zsh..."
    export RUNZSH=no
    export CHSH=no
    export USER="$(whoami)"
    EVAL "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended"
    EVAL "$ROOT chsh -s /bin/zsh \"$USER\""
    unset RUNZSH CHSH
    LOG_STEP_OUT
}

GET_OMZ_PLUGINS(){
    local PLUGINS=(
          "zsh-completions"
          "zsh-syntax-highlighting"
          "zsh-history-substring-search"
          )
    for p in "${PLUGINS[@]}"; do
        if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/$p" ]]; then
            LOG "- $p plugin not found. Installing..."
            EVAL "git clone \"https://github.com/zsh-users/$p\" \"$HOME/.oh-my-zsh/custom/plugins/$p\""
        fi
    done
}

GET_OMP()
{
    LOG "- Oh My Posh Not Found. Installing."
    [[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
    EVAL "curl -s \"https://ohmyposh.dev/install.sh\" | bash -s -- -d \"$HOME/.local/bin/\""
}

GET_OMT()
{
    LOG "- Oh my tmux not found. Installing."
    EVAL "git clone --single-branch https://github.com/gpakosz/.tmux.git \".tmux\""
    mkdir -p "$HOME/.config/tmux"
    cp -fa ".tmux/.tmux.conf" ".tmux/.tmux.conf.local" "$HOME/.config/tmux"
    rm -rf ".tmux"
}

GET_DOTFILES()
{
    local DATE="$(date +%Y%m%d)"
    local BACKUP_DIR="$HOME/.dotfiles-backup/$DATE"
    local FILES=("configs/"*)
    local I="0"

    if [[ -d "$BACKUP_DIR" ]]; then
        while [[ -d "$BACKUP_DIR" ]]; do
            I=$((I + 1))
            BACKUP_DIR="$BACKUP_DIR-$I"
            [[ -d "$BACKUP_DIR" ]] && rm -rf "$BACKUP_DIR"
        done
        mkdir -p "$BACKUP_DIR"
    else
        mkdir -p "$BACKUP_DIR"
    fi

    LOG_STEP_IN "- Copying dotfiles files."
    for f in "${FILES[@]}"; do
        if [[ -e "$HOME/.config/$f" ]]; then
            EVAL "mv -fv \"$HOME/.config/$f\" \"$BACKUP_DIR\""
        fi
        [[ -f "$HOME/.zshrc" ]] && EVAL "mv -fv \"$HOME/.zshrc\" \"$BACKUP_DIR/zshrc\""
        LOG "- Copying $f"
        DIR="$HOME/.config"
        [[ "$f" == "zshrc" ]] && DIR="$HOME/.zshrc"
        EVAL "cp -rfav \"$f\" \"$DIR\""
    done
    LOG_STEP_OUT
}

GET_BROWSER_CSS()
{
    local BROWSER="$1"

    if [[ -z "$BROWSER" ]]; then
        exit 0
    fi

    LOG "- Adding custom css for $BROWSER"
    local DIR="$(find "$HOME/.$BROWSER" -type d -name "*default-release*" -print -quit)"
    if [[ ! -d "$DIR/chrome" ]]; then
        if ! grep -q 'toolkit\.legacyUserProfileCustomizations\.stylesheets.*true' "$DIR/prefs.js"; then
            if ! grep -q 'toolkit\.legacyUserProfileCustomizations\.stylesheets.*' "$DIR/prefs.js"; then
                sed -i '/user_pref("toolkit\.legacyUserProfileCustomizations\.stylesheets",/d' "$DIR/prefs.js"
            fi
        fi
        echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$DIR/prefs.js"
        EVAL "git clone https://github.com/alfaaarex/keyfox.git \"$DIR/chrome\""
    fi
}

GET_THEFUCK()
{
    local PYTHON_VER="$(python3 --version | cut -d' ' -f2 | cut -d. -f1,2)"

    [[ -f "/usr/lib/python${PYTHON_VER}/EXTERNALLY-MANAGED" ]] && $ROOT rm -f "/usr/lib/python${PYTHON_VER}/EXTERNALLY-MANAGED"

    EVAL "pip install \"git+https://github.com/mcollard0/thefuck@fix-python-313-compatibility\""
}
# ]

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    GET_OMZ
fi
GET_OMZ_PLUGINS

# Oh My Posh
if ! CHECK_EXEC "oh-my-posh"; then
    GET_OMP
fi

# Oh My Tmux
if [[ ! -d "$HOME/.config/tmux" ]]; then
    GET_OMT
fi

# Custom css for firefox/librewolf
if [[ -d "$HOME/.librewolf" ]]; then
    BROWSER="librewolf"
elif [[ -d "$HOME/.firefox" ]]; then
    BROWSER="firefox"
fi
GET_BROWSER_CSS "$BROWSER"

# Dotfiles
GET_DOTFILES

exit 0
