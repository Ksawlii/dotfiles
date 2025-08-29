# Android SDK
if [[ -d "$HOME/android/sdk" ]]; then
    export ANDROID_HOME="$HOME/android/sdk"
fi

# Exports
EXPORT_PATH \
    "$HOME/.local/bin" \
    "$HOME/.bin" \
    "$HOME/.spicetify" \
    "$HOME/.scripts" \
    "$HOME/.local/lib" \
    "$HOME/.local/share/flatpak/exports/share/applications" \
    "$ANDROID_HOME/build-tools/35.0.1"

if [[ -f "/etc/doas.conf" ]] && CHECK_EXEC "doas"; then
    ROOT="doas"
elif CHECK_EXEC "sudo"; then
    ROOT="sudo"
else
    echo -e "\033[0;33mWARN: Neither doas nor sudo found!\033[0m"
fi

if CHECK_EXEC "nvim"; then
    export EDITOR="nvim"
    export VISUAL="nvim"
elif CHECK_EXEC "vim"; then
    export EDITOR="vim"
    export VISUAL="vim"
elif CHECK_EXEC "nano"; then
    export EDITOR="nano"
    export VISUAL="nano"
else
    echo -e "\033[0;33mWARN: No editor (nvim, vim, nano) found!\033[0m"
fi

export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/share}:/var/lib/flatpak/exports/share"
export QT_QPA_PLATFORM="wayland"
export ZSH="$HOME/.oh-my-zsh"
