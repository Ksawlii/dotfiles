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
source "$SRC_DIR/scripts/utils/common_utils.sh" || exit 1
source "$SRC_DIR/scripts/utils/log_utils.sh" || exit 1

# [
PRINT_USAGE()
{
    LOG "Usage: $0 [options]" >&2
    LOG " --no-fonts : Skip installing fonts (not recommended)" >&2
}
# ]


NO_FONTS="false"
unset BROWSER
export PARENT_NAME=$(basename "$0")

if [[ "$EUID" -eq 0 ]]; then
    ABORT "This script should not be run as root. Please run it as a regular user."
fi

while [ "$#" != 0 ]; do
    if [[ "$1" == "--no-fonts" ]]; then
        NO_FONTS=true
    elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        PRINT_USAGE
        exit 1
    else
        if [[ "$1" == "-"* ]]; then
            ABORT "Unknown option: $1"
        fi
        PRINT_USAGE
        exit 1
    fi

    shift
done

if [[ -f "/etc/doas.conf" ]] && CHECK_EXEC "doas"; then
    export ROOT="doas"
elif CHECK_EXEC "sudo"; then
    export ROOT="sudo"
else
    ABORT "Doas and sudo not found. Install doas or sudo!"
fi

LOG_STEP_IN true "Installing dependencies"
DISTRO="$(grep '^NAME=' "/etc/os-release" | cut -d= -f2 | tr -d '"')"
bash "$SRC_DIR/scripts/deps.sh" "$DISTRO" || exit 1
LOG_STEP_OUT

# Dotfiles
LOG_STEP_IN true "Setting up dotfiles"
bash "$SRC_DIR/scripts/dotfiles.sh" || exit 1
LOG_STEP_OUT

# Fonts
if [[ "$NO_FONTS" != "true" ]]; then
    LOG_STEP_IN true "Setting up fonts"
    bash "$SRC_DIR/scripts/fonts.sh" || exit 1
    LOG_STEP_OUT 
fi

echo -e '\n\033[1;32m'"Dotfiles are installed. Please reboot!"

exit 0
