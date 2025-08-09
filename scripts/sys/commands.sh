#!/bin/bash

source "$SRC_DIR/scripts/sys/logs.sh"

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
# ]
