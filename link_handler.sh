#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-06-08T11:11:47+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

input="$1"

# if no url or file given exit the script
if [ -z "$input" ]; then
    exit 1
else
    notify-send "link handler -> try to open" "$input"
fi

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
            open "$video" "tsp"
    ;;
    *mp3 \
        | *ogg \
        | *flac \
        | *opus)
            open "$podcast" "tsp"
    ;;
    *jpg \
        | *jpe \
        | *jpeg \
        | *png \
        | *gif \
        | *webp)
            open_tmp "$picture"
    ;;
    *pdf \
        | *ps \
        | *djvu \
        | *epub \
        | *cbr \
        | *cbz)
            open_tmp "$document"
    ;;
    *torrent \
        | 'magnet\:'* \
        | *metalink \
        | *iso)
            open "$download"
    ;;
    *)
        if [ -f "$input" ]; then
            open "$edit"
        else
            open "$web"
        fi
    ;;
esac
