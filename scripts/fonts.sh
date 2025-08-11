#!/bin/bash
#
# Copyright (C) 2025 Ksawlii
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

if [[ "$PARENT_NAME" != "install.sh" ]]; then
    echo "Please use the install.sh script in the root dir."
    exit 1
fi

source "$SRC_DIR/scripts/utils/common_utils.sh" || exit 1
source "$SRC_DIR/scripts/utils/log_utils.sh" || exit 1

GET_NERD(){
    local EXTRA_FONTS=(
            'MesloLGS%20NF%20Regular.ttf'
            'MesloLGS%20NF%20Bold.ttf'
            'MesloLGS%20NF%20Italic.ttf'
            'MesloLGS%20NF%20Bold%20Italic.ttf'
          )

    LOG "- Cloning nerd fonts."
    git clone -j$(nproc --all) --depth=1 -q "https://github.com/ryanoasis/nerd-fonts.git" "$HOME/nerd-fonts"
    cd "$HOME/nerd-fonts"
    LOG "- Installing nerd fonts."
    bash install.sh &>/dev/null

    for f in "${EXTRA_FONTS[@]}"; do
        wget -q "https://github.com/romkatv/powerlevel10k-media/raw/master/$f"
    done
    mv "MesloLGS NF "* "$HOME/.local/share/fonts/NerdFonts"
    cd "$SRC_DIR"
    rm -rf "$HOME/nerd-fonts"
    LOG "- Installed nerd fonts"
}

if [[ ! -d "$HOME/.local/share/fonts/NerdFonts" ]]; then
   GET_NERD
else
   LOG "- NerdFonts are already installed."
fi

exit 0
