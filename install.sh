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

set -e

if [[ ! -f "env.sh" ]]; then
    echo "Please execute install.sh from the root dir."
    exit 1
fi

source "env.sh"
source "$SRC_DIR/scripts/sys/commands.sh" || exit 1

unset BROWSER
export PARENT_NAME=$(basename "$0")

if [[ "$EUID" -eq 0 ]]; then
    error "This script should not be run as root. Please run it as a regular user."
fi

if [[ -f "/etc/doas.conf" ]] && check_exec "doas"; then
    ROOT="doas"
elif check_exec "sudo"; then
    ROOT="sudo"
else
    error "Doas and sudo not found. Install doas or sudo!"
fi

echo ""
if ask_user "Do you want to install dependencies (very recommended)?"; then
    DISTRO="$(grep -q '^NAME=' "/etc/os-release" | cut -d= -f2 | tr -d '"')"
    bash "$SRC_DIR/scripts/deps.sh" "$DISTRO" || exit 1
else
    warning "Skipping dependencies installation"
fi

# Dotfiles
bash "$SRC_DIR/scripts/dotfiles.sh" || exit 1

# Fonts
bash "$SRC_DIR/scripts/fonts.sh" || exit 1

echo ""
echo "-------------"
echo -e "Done!"
echo "-------------"

exit 0
