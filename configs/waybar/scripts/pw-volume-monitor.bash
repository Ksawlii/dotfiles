#!/bin/bash

set -e

snore()
{
    local IFS

    [ -n "${_snore_fd:-}" ] || exec {_snore_fd}<> <(:)
    read ${1:+-t "$1"} -u $_snore_fd || :
}

DELAY=0.5

SET2=(
    $'\uf6a9   '
    $'\uf026   '
    $'\uf027   '
    $'\uf028   '
)
ICON=("${SET2[@]}")

while snore $DELAY; do
    OUT=""
    INPUT="$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
    while read LINE; do
        if [[ "$LINE" =~ ^Volume:.([0-9]+)\.([0-9]{2})(([[:blank:]]\[MUTED\])?)$ ]]; then
            if [ -n "$OUT" ]; then
                OUT+="  "
            fi
            if [ -n "${BASH_REMATCH[3]}" ]; then
                OUT+="${ICON[0]}Mute  "
            else
                volume="$(( 10#${BASH_REMATCH[1]}${BASH_REMATCH[2]} ))"
                if [ "$volume" -gt 50 ]; then
                    OUT+="${ICON[3]} $volume%%   "
                elif [ "$volume" -gt 25 ]; then
                    OUT+="${ICON[2]} $volume%%   "
                elif [ "$volume" -gt 0 ]; then
                    OUT+="${ICON[1]} $volume%%   "
                else
                    OUT+="${ICON[1]}---   "
                fi
            fi
        else
            echo "Warning: Failed to match output of wpctl: '$LINE'" >&2
            exit 1
        fi
    done <<< "$INPUT"

    if [ -n "$OUT" ]; then
       printf "$OUT\n"
    fi
done

exit 0
