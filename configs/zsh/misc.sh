#!/bin/bash
# Fastfetch
CHECK_EXEC "fastfetch" && fastfetch

# ccache setup
if CHECK_EXEC "ccache"; then
    export USE_CCACHE=1
    export CCACHE_DIR="$HOME/.ccache"
    [[ ! -d "$CCACHE_DIR" ]] && mkdir -p "$CCACHE_DIR"
else
    export USE_CCACHE=0
fi

# history
setopt auto_cd
setopt correct_all
setopt hist_reduce_blanks
setopt hist_ignore_space
setopt hist_save_no_dups
