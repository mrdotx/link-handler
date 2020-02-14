#!/bin/sh

# path:       ~/projects/newsboat/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/newsboat
# date:       2020-02-14T09:35:20+0100

movies="mpv --really-quiet"
podcasts="$TERMINAL -e mpv --no-audio-display"
pictures="sxiv -a -s f"

# if no url given open browser
[ -z "$1" ] && {
    notify-send "link handler" "no url given, open browser..." \
        && "$BROWSER"
    exit
}

case "$1" in
*mkv | *webm | *mp4 | *youtube.com/watch* | *youtube.com/playlist* | *youtu.be*)
    notify-send "link handler" "open url in multimedia player:\n$1" \
        && eval tsp "$movies --input-ipc-server=/tmp/mpvsoc$(date +%s) $1 >/dev/null 2>&1" &
    ;;
*mp3 | *flac | *opus)
    notify-send "link handler" "open url in multimedia player:\n$1" \
        && eval tsp "$podcasts --input-ipc-server=/tmp/mpvsoc$(date +%s) $1 >/dev/null 2>&1" &
    ;;
*png | *jpg | *jpe | *jpeg | *gif)
    notify-send "link handler" "open url in picture viewer:\n$1" \
        && curl -sL "$1" >"/tmp/$(echo "$1" | sed "s/.*\///")" \
        && $pictures "/tmp/$(echo "$1" | sed "s/.*\///")" >/dev/null 2>&1 &
    ;;
*)
    if [ -f "$1" ]; then
        notify-send "link handler" "open url in editor:\n$1" \
            && eval "$TERMINAL -e $EDITOR $1" &
    else
        notify-send "link handler" "open url in browser:\n$1" \
            && eval "$BROWSER $1 >/dev/null 2>&1" &
    fi
    ;;
esac
