#!/bin/bash
set -e

if [ "$EUID" -eq 0 ]; then
  error "This script should not be run as root. Please run it as a regular user."
fi

# Commands (1)
cmd_chk() {
  command -v "$1" &>/dev/null
}

error() {
  local RED="\e[0;31m"

  echo -e "${RED}E: $1${R}" >&2
  exit 1
}

if [ -f "/etc/doas.conf" ] && "cmd_chk" "doas"; then
  ROOT="doas"
elif "cmd_chk" "sudo"; then
  ROOT="sudo"
else
  error "Doas and sudo not found. Install doas or sudo!"
fi

# Variable(s)
R="\e[0m"

# Commands (2)
ask_ny() {
  while true; do
    read -p "$1 (y/n): " ny
    case $ny in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
          * ) echo -e "Please answer y or n.";;
    esac
  done
}

warning() {
  local ORANGE="\e[0;33m"

  echo -e "${ORANGE}W: $1${R}" >&2
}

info() {
  echo -e "I: $1" >&2
}

unmask() {
  local I="${1}/${2} ~amd64"
  local PCK_KEYWORDS="/etc/portage/package.accept_keywords"

  [ ! -d "$PCK_KEYWORDS" ] && "$ROOT" mkdir -p "$PCK_KEYWORDS"

  if ! grep -Fxq "$I" "$PCK_KEYWORDS/$1" 2>/dev/null; then
    if [ ! -f "$PCK_KEYWORDS/$1" ]; then
      "$ROOT" touch "$PCK_KEYWORDS/$1"
    fi
    echo "$I" | "$ROOT" tee -a "$PCK_KEYWORDS/$1" > /dev/null
  fi
}

gentoo(){
  local TO_UNMASK=( media-gfx/timg gui-apps/wlogout
                    x11-apps/xcur2png app-misc/nwg-look
                    gui-apps/satty gui-apps/gtklock gui-libs/gtk-session-lock )
  local DEPS=( hyprland wlogout waybar rofi neovim xdg-desktop-portal swaybg
               xdg-desktop-portal-wlr thunar kitty dev-perl/Gtk2 wl-clipboard
               sys-apps/dbus timg dunst gtklock dev-perl/Gtk3 xcur2png nwg-look fastfetch
               zsh grim slurp satty wlroots xdg-desktop-portal-gtk tmux )
  local REPOS=( kzd guru steam-overlay )
  local MISSING

  "$ROOT" emerge -q --sync

  if ! "cmd_chk" "equery"; then
    "$ROOT" emerge -avq app-portage/gentoolkit
  fi

  if ! eselect "repository" &>/dev/null; then
    "$ROOT" emerge -navq eselect-repository
  fi

  for r in "${REPOS[@]}"; do
    if ! grep -q "^\[$r\]" "/etc/portage/repos.conf/eselect-repo.conf"; then
      "$ROOT" eselect repository enable "$r"
    fi
  done

  for d in "${DEPS[@]}"; do
    if ! equery list "$d" >/dev/null 2>&1; then
		  MISSING+=("$d")
      for u in "${TO_UNMASK[@]}"; do
        CTG="${u%%/*}"
        PKG="${u##*/}"
        if [ "$PKG" = "$d" ]; then
          unmask "$CTG" "$PKG"
        fi
      done
		fi
	done

  if [ ${#MISSING[@]} -gt 0 ]; then
    "$ROOT" emerge -avq ${MISSING[@]}
  else
    info "Nevermind, looks like you got every dependency already"
  fi

  if [ -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
    if ! grep -q "Exec=dbus-run-session Hyprland" /usr/share/wayland-sessions/hyprland.desktop; then
      echo -e ""
      info "Patching hyprland.desktop to run with dbus"
      "$ROOT" sed -i "s.Exec\=Hyprland.Exec=dbus-run-session\ Hyprland.g" /usr/share/wayland-sessions/hyprland.desktop
    fi
  else
    warn "/usr/share/wayland-sessions/hyprland.desktop not found."
  fi
}

arch(){
  local DEPS=( hyprland waybar rofi python-pipx kitty xdg-desktop-portal neovim
               gtk2 gtk3 nwg-look fastfetch zsh grim satty xdg-desktop-portal-gtk
               swaybg thunar xcur2png gsettings-qt slurp wlogout wl-clipboard
               xdg-desktop-portal-wlr dunst dbus timg gtklock tmux )
  local MISSING="$(pacman -T "${DEPS[@]}" 2>/dev/null)"

  if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | "$ROOT" tee -a /etc/pacman.conf
  fi
  
  if ! "cmd_chk" "yay"; then
    echo -e ""
    info "Yay not installed. Installing yay (AUR helper)..."
    "$ROOT" pacman -S --needed base-devel git
    git clone "https://aur.archlinux.org/yay.git" "$HOME/.yay"
    cd "$HOME/.yay"
    makepkg -si
    rm -rf "$HOME/.yay"
  fi
  
  if [ -n "$MISSING" ]; then
	  echo -e ""
    "$ROOT" yay -Syyuu --needed --noconfirm "$MISSING"
	else
    info "Nevermind, looks like you got every dependency already"
  fi
}

if grep -q "gentoo" "/etc/os-release"; then
  DISTRO(){ gentoo; }
  DISTRO_NAME="Gentoo"
elif grep -q "arch" "/etc/os-release"; then
  DISTRO(){ arch; }
  DISTRO_NAME="Arch"
else
  error "Your distro is not supported"
fi

echo -e ""
info "$DISTRO_NAME Linux detected"
echo -e ""
if ask_ny "Do you want to install dependencies (very recommended)?"; then
  DISTRO
else
  warning "Skipping dependencies installation"
  SKIPPED="1"
fi

# Oh My Zsh
if [ ! "$SKIPPED" = "1" ]; then
  echo -e ""
  unset SKIPPED
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing Oh My Zsh."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Oh My Zsh Plugins
PLUGINS=(
  zsh-completions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

for p in "${PLUGINS[@]}"; do
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/$p" ]; then 
      info "$p plugin not found. Installing."
      git clone -q "https://github.com/zsh-users/$p" "$HOME/.oh-my-zsh/custom/plugins/$p"
  fi
done

# Oh My Posh
if ! "cmd_chk" "oh-my-posh"; then
  info "Oh My Posh Not Found. Installing."
  if [ ! -d "$HOME/.local/bin/" ]; then
    mkdir -p "$HOME/.local/bin/"
  fi
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin/" &> /dev/null
  NOT_FOUND="1"
fi

if [ "$NOT_FOUND" != "1" ]; then
  echo -e ""
  unset NOT_FOUND
fi

if [ ! -d "$HOME/.config/" ]; then
    mkdir -p "$HOME/.config/" 
fi

# Dotfiles
info "Copying dotfiles files"
sleep 1

FILES=(configs/*)

for f in "${FILES[@]}"; do
  if [ -d "$HOME/.config/$f" ]; then
    mkdir -p "$HOME/.dotfiles-backup"
    mv -f "$HOME/.config/$f" "$HOME/.dotfiles-backup/"
  fi

  echo "  - Copying $f"
  cp -rfa "$f" "$HOME/.config/"
done

if [ -f "$HOME/.zshrc" ]; then
  [ ! -d "$HOME/.dotfiles-backup" ] && mkdir -p "$HOME/.dotfiles-backup"
  mv -f "$HOME/.zshrc" "$HOME/.dotfiles-backup/zshrc"
fi
mv -f "$HOME/.config/zsh/zshrc" "$HOME/.zshrc"

# TEMP
# Oh my tmux
if [ ! -d ".tmux" ]; then
  info "Oh my tmux not found. Installing."
  git clone --single-branch https://github.com/gpakosz/.tmux.git ".tmux"
  mkdir -p "$HOME/.config/tmux"
  cp ".tmux/.tmux.conf" ".tmux/tmux.conf.local" "$HOME/.config/tmux/tmux.conf"
  rm -rf ".tmux"
fi

# Nerd Fonts
echo -e ""
if [ ! -d "$HOME/nerd-fonts/" ]; then
  if ask_ny "Do you want Nerd Fonts (Recommended) (8GB)?"; then
    git clone -j$(nproc --all) --depth=1 "https://github.com/ryanoasis/nerd-fonts.git" "$HOME/nerd-fonts"
    cd "$HOME/nerd-fonts/"
    ./install.sh
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
    mv MesloLGS\ NF\ * "$HOME/.local/share/fonts/NerdFonts/"
    rm -rf "$HOME/nerd-fonts"
  fi
fi
sleep 1
echo "-------------"
echo -e "Done!"
echo "-------------"

exit 0

