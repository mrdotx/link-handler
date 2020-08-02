#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-08-02T10:27:03+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

input="$1"

# if no url/file given exit the script
[ -z "$input" ] && exit 1

# open in application and if given, open with tsp (taskspooler)
open() {
    eval "$2" "$1 $input >/dev/null 2>&1" &
}

# download file to tmp directory before open it
open_tmp() {
    curl -sL "$input" >"/tmp/$(printf "%s" "$input" \
        | sed "s/.*\///")" \
        && eval "$1 /tmp/$(printf "%s" "$input" \
        | sed "s/.*\///") >/dev/null 2>&1" &
}


case "$input" in
    *mkv \
        | *mp4 \
        | *webm \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send "link handler - add video to taskspooler" "$input"
            open "$video" "tsp"
    ;;
    *mp3 \
        | *ogg \
        | *flac \
        | *opus)
            notify-send "link handler - add audio to taskspooler" "$input"
            open "$podcast" "tsp"
    ;;
    *jpg \
        | *jpe \
        | *jpeg \
        | *png \
        | *gif \
        | *webp)
            notify-send "link handler - open picture" "$input"
            open_tmp "$picture"
    ;;
    *pdf \
        | *ps \
        | *djvu \
        | *epub \
        | *cbr \
        | *cbz)
            notify-send "link handler - open document" "$input"
            open_tmp "$document"
    ;;
    *torrent \
        | 'magnet\:'* \
        | *metalink \
        | *iso)
            notify-send "link handler - download file" "$input"
            open "$download"
    ;;
    *)
        if [ -f "$input" ]; then
            notify-send "link handler - edit file" "$input"
            open "$edit"
        else
            notify-send "link handler - open link" "$input"
            open "$web"
        fi
    ;;
esac
