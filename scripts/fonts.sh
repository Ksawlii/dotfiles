#!/bin/bash

if [[ "$PARENT_NAME" != "install.sh" ]]; then
    echo "Please use the install.sh script in the root dir."
    exit 1
fi

source "$SRC_DIR/scripts/sys/commands.sh"
source "$SRC_DIR/scripts/sys/logs.sh"

nerd(){
    if ask_user "Do you want Nerd Fonts (Recommended) (8GB)?"; then
        git clone -j$(nproc --all) --depth=1 "https://github.com/ryanoasis/nerd-fonts.git" "$HOME/nerd-fonts"
        cd "$HOME/nerd-fonts"
        ./install.sh

        FONTS=(
            'MesloLGS%20NF%20Regular.ttf'
            'MesloLGS%20NF%20Bold.ttf'
            'MesloLGS%20NF%20Italic.ttf'
            'MesloLGS%20NF%20Bold%20Italic.ttf'
        )
        for f in "${FONTS[@]}"; do
            wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/$f"
        done
        mv "MesloLGS NF "* "$HOME/.local/share/fonts/NerdFonts"
        cd "$SRC_DIR"
        rm -rf "$HOME/nerd-fonts"
    fi
}

if [[ ! -d "$HOME/nerd-fonts" ]]; then
    nerd
fi
