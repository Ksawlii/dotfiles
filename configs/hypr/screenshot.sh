[[ ! -d "$HOME/Pictures/screenshots" ]] && mkdir -p "$HOME/Pictures/screenshots"

TMP_PNG=$(mktemp --suffix=.png) \
    && grim -g "$(slurp)" -t png "$TMP_PNG" \
    && tee "$HOME/Pictures/screenshots/$(date '+%Y-%m-%d_%H-%M').png" < "$TMP_PNG" \
    | satty --early-exit --initial-tool rectangle --copy-command wl-copy --annotation-size-factor 2 --filename - \
    && rm "$TMP_PNG"
