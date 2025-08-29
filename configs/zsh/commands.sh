#!/bin/bash
# [
CHECK_EXEC()
{
    command -v "$1" &> /dev/null
    return $?
}

EXPORT_PATH()
{
    for dir in "$@"; do
        [[ -d "$dir" ]] && export PATH="$PATH:$dir"
    done
}

command_not_found_handler()
{
    printf "%s%s?! Learn how to type dumbass fr\n" "$acc" "$0" >&2
    return 127
}
# ]
