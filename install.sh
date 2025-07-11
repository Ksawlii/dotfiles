#!/bin/bash

set -e

# [
# https://github.com/saadelasfur/distro-setup-utils/blob/98f8764c83b8254e2a6ec3da1d5cd66a7d1f024b/scripts/utils/common_utils.sh#L36-L58
ask_user()
{
    local ANSWER
    local PROMPT="$1 [y/n] "

    while true; do
        read -rp "$PROMPT" ANSWER
        case "${ANSWER,,}" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                warning "Please answer yes or no"
                ;;
        esac
    done
}

check_exec()
{
    command -v "$1" &> /dev/null
    return $?
}

error()
{
    local RED="\033[0;31m"
    local RST="\033[0m"

    echo -e "${RED}ERROR: ${1}${RST}" >&2
    exit 1
}

info()
{
    echo -e "INFO: $1" >&2
}

setup_arch()
{
    local DEPS=""
    local MISSING

    DEPS="hyprland waybar rofi python-pipx dbus kitty xdg-desktop-portal gtk2 gtk3 \
    neovim nwg-look fastfetch zsh grim satty xdg-desktop-portal-gtk swaybg thunar xcur2png \
    gsettings-qt slurp wlogout wl-clipboard xdg-desktop-portal-wlr dunst timg gtklock tmux playerctl cava"

    if ! grep -q "^\[multilib\]" "/etc/pacman.conf"; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | $ROOT tee -a "/etc/pacman.conf"
    fi

    if ! check_exec "yay"; then
        echo -e ""
        info "Yay not installed. Installing yay (AUR helper)..."
        $ROOT pacman -S --needed base-devel git
        git clone "https://aur.archlinux.org/yay.git" "$HOME/.yay"
        cd "$HOME/.yay"
        makepkg -si
        rm -rf "$HOME/.yay"
    fi

    echo -e ""
    yay -Syyuu --needed --noconfirm "$DEPS"
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
        "fastfetch" "zsh" "grim" "slurp" "satty"
        "wlroots" "xdg-desktop-portal-gtk" "tmux" "playerctl" "cava"
    )
    REPOS+=(
        "kzd" "guru" "steam-overlay"
    )

    $ROOT emerge -q --sync

    if ! check_exec "equery"; then
        $ROOT emerge -avq app-portage/gentoolkit
    fi
    if ! eselect "repository" &> /dev/null; then
        $ROOT emerge -navq eselect-repository
    fi

    for r in "${REPOS[@]}"; do
        if ! grep -q "^\[$r\]" "/etc/portage/repos.conf/eselect-repo.conf"; then
            $ROOT eselect repository enable "$r"
        fi
    done

    for d in "${DEPS[@]}"; do
        if ! equery list "$d" > /dev/null 2>&1; then
            MISSING+=("$d")
            for u in "${TO_UNMASK[@]}"; do
                CTG="${u%%/*}"
                PKG="${u##*/}"
                if [ "$PKG" == "$d" ]; then
                    unmask "$CTG" "$PKG"
                fi
            done
        fi
    done

    if [ "${#MISSING[@]}" -gt 0 ]; then
        $ROOT emerge -avq "${MISSING[@]}"
    else
        info "Nevermind, looks like you got every dependency already"
    fi

    if [ -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
        if ! grep -q "Exec=dbus-run-session Hyprland" "/usr/share/wayland-sessions/hyprland.desktop"; then
            echo -e ""
            info "Patching hyprland.desktop to run with dbus"
            $ROOT sed -i "s.Exec\=Hyprland.Exec=dbus-run-session\ Hyprland.g" "/usr/share/wayland-sessions/hyprland.desktop"
        fi
    else
        warn "/usr/share/wayland-sessions/hyprland.desktop not found."
    fi
}

unmask()
{
    local I="${1}/${2} ~amd64"
    local PCK_KEYWORDS="/etc/portage/package.accept_keywords"

    [ ! -d "$PCK_KEYWORDS" ] && $ROOT mkdir -p "$PCK_KEYWORDS"
    if ! grep -Fxq "$I" "$PCK_KEYWORDS/$1" 2> /dev/null; then
        if [ ! -f "$PCK_KEYWORDS/$1" ]; then
            $ROOT touch "$PCK_KEYWORDS/$1"
        fi
        echo "$I" | $ROOT tee -a "$PCK_KEYWORDS/$1" > /dev/null
    fi
}

warning()
{
    local ORG="\033[0;33m"
    local RST="\033[0m"

    echo -e "${ORG}WARN: ${1}${RST}" >&2
}
# ]

if [ "$EUID" -eq 0 ]; then
    error "This script should not be run as root. Please run it as a regular user."
fi

if [ -f "/etc/doas.conf" ] && check_exec "doas"; then
    ROOT="doas"
elif check_exec "sudo"; then
    ROOT="sudo"
else
    error "Doas and sudo not found. Install doas or sudo!"
fi

if grep -qi "gentoo" "/etc/os-release"; then
    DISTRO="Gentoo"
elif grep -qi "arch" "/etc/os-release"; then
    DISTRO="Arch"
else
    error "Your distro is not supported!"
fi

echo -e ""
info "$DISTRO Linux detected"

echo -e ""
if ask_user "Do you want to install dependencies (very recommended)?"; then
    case "$DISTRO" in
        Gentoo)
            setup_gentoo
            ;;
        Arch)
            setup_arch
            ;;
    esac
else
    warning "Skipping dependencies installation"
    SKIPPED=true
fi

# Oh My Zsh
if ! $SKIPPED; then
    echo -e ""
    unset SKIPPED
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    export RUNZSH=no
    export CHSH=no
    export USER="$(whoami)"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &> /dev/null
    $ROOT chsh -s /bin/zsh "$USER"
fi

# Oh My Zsh Plugins
PLUGINS=(
    "zsh-completions"
    "zsh-syntax-highlighting"
    "zsh-history-substring-search"
)
for p in "${PLUGINS[@]}"; do
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$p" ]; then
        info "$p plugin not found. Installing..."
        git clone -q "https://github.com/zsh-users/$p" "$HOME/.oh-my-zsh/custom/plugins/$p"
    fi
done

# Oh My Posh
if ! check_exec "oh-my-posh"; then
    info "Oh My Posh Not Found. Installing..."
    [ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin/" &> /dev/null
    NOT_FOUND=true
fi

if ! $NOT_FOUND; then
    echo -e ""
    unset NOT_FOUND
fi

[ ! -d "$HOME/.config" ] && mkdir -p "$HOME/.config"

# Oh my tmux
if [ ! -d "$HOME/.config/tmux" ]; then
    info "Oh my tmux not found. Installing..."
    git clone --single-branch -q https://github.com/gpakosz/.tmux.git ".tmux"
    mkdir -p "$HOME/.config/tmux"
    cp -fa ".tmux/.tmux.conf" ".tmux/.tmux.conf.local" "$HOME/.config/tmux"
    rm -rf ".tmux"
    echo ""
fi

# Dotfiles
info "Copying dotfiles files"
sleep 1

FILES=("configs/"*)
for f in "${FILES[@]}"; do
    if [ -d "$HOME/.config/$f" ]; then
        mkdir -p "$HOME/.dotfiles-backup"
        mv -f "$HOME/.config/$f" "$HOME/.dotfiles-backup"
    fi
    echo "- Copying $f"
    cp -rfa "$f" "$HOME/.config"
done

if [ -f "$HOME/.zshrc" ]; then
    [ ! -d "$HOME/.dotfiles-backup" ] && mkdir -p "$HOME/.dotfiles-backup"
    mv -f "$HOME/.zshrc" "$HOME/.dotfiles-backup/zshrc"
fi
mv -f "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"

# Nerd Fonts
echo -e ""
if [ ! -d "$HOME/nerd-fonts" ]; then
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
            wget https://github.com/romkatv/powerlevel10k-media/raw/master/$f
        done
        mv "MesloLGS NF "* "$HOME/.local/share/fonts/NerdFonts"
        rm -rf "$HOME/nerd-fonts"
    fi
fi

sleep 1
echo ""
echo "-------------"
echo -e "Done!"
echo "-------------"

exit 0
