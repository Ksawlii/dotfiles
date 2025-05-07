TMP_PNG=$(mktemp --suffix=.png) && \

grim -g "$(slurp)" -t png "$TMP_PNG" && \
tee ~/ss17/$(date '+%Y-%m-%d_%H-%M').png < "$TMP_PNG" | \
satty --early-exit --initial-tool rectangle --copy-command wl-copy --annotation-size-factor 2 --filename - && \

rm "$TMP_PNG"
