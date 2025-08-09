#!/bin/bash

# [
# shellcheck disable=SC1007,SC2164
# https://android.googlesource.com/platform/build/+/refs/tags/android-15.0.0_r1/envsetup.sh#18
_GET_SRC_DIR()
{
    local TOPFILE="install.sh"
    if [[ -n "$SRC_DIR" ]] && [[ -f "$SRC_DIR/$TOPFILE" ]]; then
        # The following circumlocution ensures we remove symlinks from SRC_DIR.
        (cd "$SRC_DIR"; PWD= /bin/pwd)
    else
        if [[ -f "$TOPFILE" ]]; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            local HERE="$PWD"
            local T=
            while [ \( ! \( -f "$TOPFILE" \) \) ] && [ \( "$PWD" != "/" \) ]; do
                \cd ..
                T="$(PWD= /bin/pwd -P)"
            done
            \cd "$HERE"
            if [[ -f "$T/$TOPFILE" ]]; then
                echo "$T"
            fi
        fi
    fi
}
# ]

# https://github.com/salvogiangri/UN1CA/blob/fifteen/buildenv.sh#L108-L112
export SRC_DIR="$(_GET_SRC_DIR)"
if [[ ! "$SRC_DIR" ]]; then
    echo "Couldn't locate the top of the tree. Always source env.sh from the root of the tree." >&2
    return 1
fi
