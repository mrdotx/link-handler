#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-06-01T12:33:30+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

data="$1"

# if no url or file given exit the script
if [ -z "$data" ]; then
    exit 1
else
    notify-send "link handler -> try to open" "$data"
fi

# open in application and if given, open with tsp (taskspooler)
open(){
    eval "$2" "$1 $data >/dev/null 2>&1" &
}

# download file to tmp directory before open it
open_tmp(){
    curl -sL "$data" >"/tmp/$(printf "%s" "$data" \
        | sed "s/.*\///")" \
        && eval "$1 /tmp/$(printf "%s" "$data" \
        | sed "s/.*\///") >/dev/null 2>&1" &
}


case "$data" in
    *mkv \
        | *mp4 \
        | *webm \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            open "$video" "tsp"
    ;;
    *mp3 \
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
        if [ -f "$data" ]; then
            open "$edit"
        else
            open "$web"
        fi
    ;;
esac
