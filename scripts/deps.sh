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

source "$SRC_DIR/scripts/sys/log_utils.sh"

# [
setup_arch()
{
    local DEPS=""
    local MISSING

    DEPS="hyprland waybar rofi python-pipx dbus kitty xdg-desktop-portal gtk2 gtk3 \
    neovim nwg-look fastfetch zsh grim satty xdg-desktop-portal-gtk swaybg thunar xcur2png hyfetch \
    gsettings-qt slurp wlogout wl-clipboard xdg-desktop-portal-wlr dunst timg gtklock tmux playerctl cava"

    if ! grep -q "^\[multilib\]" "/etc/pacman.conf"; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | $ROOT tee -a "/etc/pacman.conf"
    fi

    if ! check_exec "yay"; then
        echo -e ""
        LOG_STEP_IN "- Yay not installed. Installing yay (AUR helper)..."
        $ROOT pacman -S --needed base-devel git
        git clone -q "https://aur.archlinux.org/yay.git" "$HOME/.yay"
        cd "$HOME/.yay"
        makepkg -si >/dev/null
        rm -rf "$HOME/.yay"
        LOG_STEP_OUT
    fi

    LOG "- Running a full system update with yay"
    yay -Syyuu --needed --noconfirm

    LOG "- Installing dependencies"
    yay -S --needed --noconfirm "$DEPS"
}

setup_gentoo()
{
    local TO_UNMASK=()
    local DEPS=()
    local REPOS=()
    local MISSING=()

    TO_UNMASK+=(
        "media-gfx/timg" "gui-apps/wlogout" "x11-apps/xcur2png"
        "app-misc/nwg-look" "gui-apps/satty" "gui-apps/gtklock" "gui-libs/gtk-session-lock"
    )
    DEPS+=(
        "hyprland" "wlogout" "waybar" "rofi"
        "neovim" "xdg-desktop-portal" "swaybg" "xdg-desktop-portal-wlr" "thunar"
        "kitty" "dev-perl/Gtk2" "wl-clipboard" "sys-apps/dbus" "timg"
        "dunst" "gtklock" "dev-perl/Gtk3" "xcur2png" "nwg-look"
        "fastfetch" "zsh" "grim" "slurp" "satty" "hyfetch"
        "wlroots" "xdg-desktop-portal-gtk" "tmux" "playerctl" "cava"
    )
    REPOS+=(
        "kzd" "guru" "steam-overlay"
    )

    $ROOT emerge -q --sync

    if ! check_exec "equery"; then
        LOG "- equery not found. Installing."
        $ROOT emerge -avq app-portage/gentoolkit
    fi
    if ! eselect "repository" &> /dev/null; then
        LOG "- eselect-repository not found. Installing. "
        $ROOT emerge -navq eselect-repository
    fi

    for r in "${REPOS[@]}"; do
        if ! grep -q "^\[[$r\]]" "/etc/portage/repos.conf/eselect-repo.conf"; then
            $ROOT eselect repository enable "$r"
        fi
    done

    for d in "${DEPS[@]}"; do
        if ! equery list "$d" > /dev/null 2>&1; then
            MISSING+=("$d")
            for u in "${TO_UNMASK[@]}"; do
                CTG="${u%%/*}"
                PKG="${u##*/}"
                if [[ "$PKG" == "$d" ]]; then
                    unmask "$CTG" "$PKG"
                fi
            done
        fi
    done

    if [[ "${#MISSING[[@]]}" -gt 0 ]]; then
        LOG "- Installing dependencies."
        $ROOT emerge -avq "${MISSING[[@]]}"
    else
        LOG "- Nevermind, looks like you got every dependency already"
    fi

    if [[ -f "/usr/share/wayland-sessions/hyprland.desktop" ]]; then
        if ! grep -q "Exec=dbus-run-session Hyprland" "/usr/share/wayland-sessions/hyprland.desktop"; then
            LOG "- Patching hyprland.desktop to run with dbus"
            $ROOT sed -i "s.Exec\=Hyprland.Exec=dbus-run-session\ Hyprland.g" "/usr/share/wayland-sessions/hyprland.desktop"
        fi
    else
        LOGW "- /usr/share/wayland-sessions/hyprland.desktop not found. Skipping dbus patch."
    fi
}

unmask()
{
    local I="${1}/${2} ~amd64"
    local PCK_KEYWORDS="/etc/portage/package.accept_keywords"

    [[ ! -d "$PCK_KEYWORDS" ]] && $ROOT mkdir -p "$PCK_KEYWORDS"
    if ! grep -Fxq "$I" "$PCK_KEYWORDS/$1" 2> /dev/null; then
        if [[ ! -f "$PCK_KEYWORDS/$1" ]]; then
            $ROOT touch "$PCK_KEYWORDS/$1"
        fi
        echo "$I" | $ROOT tee -a "$PCK_KEYWORDS/$1" > /dev/null
    fi
}
# ]

if [[ "$1" = "Gentoo" ]]; then
    setup_gentoo
elif [[ "$1" = "Arch Linux" ]]; then
    setup_arch
else
    LOGE "Your Distro is not supported ($1)"
fi
