#!/bin/bash

if [[ "$PARENT_NAME" != "install.sh" ]]; then
    echo "Please use the install.sh script in the root dir."
    exit 1
fi

source "$SRC_DIR/scripts/sys/commands.sh" || exit 1
source "$SRC_DIR/scripts/sys/logs.sh" || exit 1

omz()
{
    info "Installing Oh My Zsh..."
    export RUNZSH=no
    export CHSH=no
    export USER="$(whoami)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null
    $ROOT chsh -s /bin/zsh "$USER"
    unset RUNZSH CHSH
}

omz_plugins(){
    local PLUGINS=(
          "zsh-completions"
          "zsh-syntax-highlighting"
          "zsh-history-substring-search"
          )
    for p in "${PLUGINS[@]}"; do
        if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/$p" ]]; then
            info "$p plugin not found. Installing..."
            git clone -q "https://github.com/zsh-users/$p" "$HOME/.oh-my-zsh/custom/plugins/$p"
        fi
    done
}

omp()
{
    info "Oh My Posh Not Found. Installing..."
    [[ ! -d "$HOME/.local/bin" ]] && mkdir -p "$HOME/.local/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin/" &> /dev/null
}

omt()
{
    info "Oh my tmux not found. Installing..."
    git clone --single-branch -q https://github.com/gpakosz/.tmux.git ".tmux"
    mkdir -p "$HOME/.config/tmux"
    cp -fa ".tmux/.tmux.conf" ".tmux/.tmux.conf.local" "$HOME/.config/tmux"
    rm -rf ".tmux"
}

dotfiles()
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
            mkdir -p "$BACKUP_DIR"
        done
    else
        mkdir -p "$BACKUP_DIR"
    fi

    if [[ -d "$HOME/.librewolf" ]]; then
        local BROWSER=".librewolf"
    elif [[ -d "$HOME/.firefox" ]]; then
        local BROWSER=".firefox"
    fi

    info "Copying dotfiles files..."
    for f in "${FILES[@]}"; do
        if [[ -e "$HOME/.config/$f" ]]; then
            mv -f "$HOME/.config/$f" "$BACKUP_DIR"
        fi
        echo "- Copying $f"
        cp -rfa "$f" "$HOME/.config"
    done

    [[ -f "$HOME/.zshrc" ]] && mv -f "$HOME/.zshrc" "$BACKUP_DIR/zshrc"

    mv -f "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"

    if [[ -n $BROWSER ]]; then
        local DIR="$(find "$HOME/$BROWSER" -type d -name "*default-release*" -print -quit)"
        if [[ ! -d "$DIR/chrome" ]]; then
            if ! grep -q 'toolkit\.legacyUserProfileCustomizations\.stylesheets.*true' "$DIR/prefs.js"; then
                if ! grep -q 'toolkit\.legacyUserProfileCustomizations\.stylesheets.*' "$DIR/prefs.js"; then
                    sed -i '/user_pref("toolkit\.legacyUserProfileCustomizations\.stylesheets",/d' "$DIR/prefs.js"
                fi
            fi
            echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$DIR/prefs.js"
            git clone -q "https://github.com/alfaaarex/keyfox.git" "$DIR/chrome"
        fi
    fi
}

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    omz
fi
omz_plugins

# Oh My Posh
if ! check_exec "oh-my-posh"; then
    omp
fi

# Oh My Tmux
if [[ ! -d "$HOME/.config/tmux" ]]; then
    omt
fi

# Dotfiles
dotfiles
