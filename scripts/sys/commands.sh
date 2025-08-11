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

source "$SRC_DIR/scripts/sys/log_utils.sh"

# [
# https://github.com/saadelasfur/distro-setup-utils/blob/98f8764c83b8254e2a6ec3da1d5cd66a7d1f024b/scripts/utils/common_utils.sh#L36-L58
ask_user()
{
    local ANSWER
    local PROMPT="$1 [y/n] "

    while true; do
        _SET_INDENT
        read -rp "$PROMPT" ANSWER
        case "${ANSWER,,}" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                LOGW "! Please answer yes or no"
                ;;
        esac
    done
}

check_exec()
{
    command -v "$1" &> /dev/null
    return $?
}
# ]
