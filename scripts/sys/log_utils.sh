#!/bin/bash
#
# Copyright (C) 2025 salvogiangri
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

# https://github.com/salvogiangri/UN1CA/blob/9709f2557a63a27530ca6b2b0e7f9d007233a063/scripts/utils/log_utils.sh#L43-L104

# [
_SET_INDENT()
{
    local INDENT="${INDENT_LEVEL:=0}"
    while [[ "$INDENT" -gt 0 ]]; do
        echo -n " "
        INDENT="$((INDENT - 1))"
    done
}
# ]

# LOG <message>
# Prints a log message.
LOG()
{
    _SET_INDENT
    echo -e "$1"
}

# LOGE <message>
# Prints an error log message.
LOGE()
{
    local RED="\033[0;31m"
    local RESET="\033[0m"

    _SET_INDENT
    echo -e "${RED}${1}${RESET}" >&2
}

# LOGW <message>
# Prints a warning log message.
LOGW()
{
    local YELLOW="\033[0;33m"
    local RESET="\033[0m"

    _SET_INDENT
    echo -e "${YELLOW}${1}${RESET}" >&2
}

# LOG_STEP_IN <bold> <message>
# Increments the output indentation, additionally prints a log message if supplied.
LOG_STEP_IN()
{
    local BOLD
    local RESET="\033[0m"

    if [[ "$1" == "true" ]]; then
        BOLD="\033[1;37m"
        shift
    fi

    if [[ "$1" ]]; then
        LOG "${BOLD}${1}${RESET}"
    fi

    local INDENT="${INDENT_LEVEL:=0}"
    export INDENT_LEVEL="$((INDENT + 2))"
}

# LOG_STEP_OUT
# Reduces the output indentation.
LOG_STEP_OUT()
{
    local INDENT="${INDENT_LEVEL:=0}"
    if [[ "$INDENT_LEVEL" -gt 0 ]]; then
        export INDENT_LEVEL=$((INDENT - 2))
    fi
}
