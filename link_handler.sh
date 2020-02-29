#!/bin/sh

# path:       ~/repos/newsboat/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/newsboat
# date:       2020-02-29T22:25:04+0100

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display --input-ipc-server=/tmp/mpvsoc$(date +%s)"
video="mpv --really-quiet --input-ipc-server=/tmp/mpvsoc$(date +%s)"
picture="sxiv -a -s f"
document="zathura"

# if no file/url given open browser
[ -z "$1" ] && {
    notify-send "link handler" "no url/file given, exit..."
    exit
}

case "$1" in
    *mkv | *mp4 | *webm | *youtube.com/watch* | *youtube.com/playlist* | *youtu.be*)
        notify-send "link handler" "open url in video player:\n$1" \
            && eval tsp "$video $1 >/dev/null 2>&1" &
    ;;
    *mp3 | *flac | *opus)
        notify-send "link handler" "open url in audio player:\n$1" \
            && eval tsp "$podcast $1 >/dev/null 2>&1" &
    ;;
    *jpg | *jpe | *jpeg | *png | *gif | *webp)
        notify-send "link handler" "open url in picture viewer:\n$1" \
            && curl -sL "$1" >"/tmp/$(printf "%s" "$1" | sed "s/.*\///")" \
            && eval "$picture /tmp/$(printf "%s" "$1" | sed "s/.*\///") >/dev/null 2>&1" &
    ;;
    *pdf | *ps | *djvu | *epub | *cbr | *cbz)
        notify-send "link handler" "open url in document viewer:\n$1" \
            && curl -sL "$1" >"/tmp/$(printf "%s" "$1" | sed "s/.*\///")" \
            && eval "$document /tmp/$(printf "%s" "$1" | sed "s/.*\///") >/dev/null 2>&1" &
    ;;    *)
        if [ -f "$1" ]; then
            notify-send "link handler" "open url in editor:\n$1" \
                && eval "$edit $1 >/dev/null 2>&1" &
        else
            notify-send "link handler" "open url in browser:\n$1" \
                && eval "$web $1 >/dev/null 2>&1" &
        fi
    ;;
esac
