#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/newsboat
# date:       2020-05-03T01:50:12+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

data="$1"

# if no url or file given exit the application
[ -z "$data" ] && {
    notify-send "link handler [error]" "no url or file given, exit..."
    exit
}

# open in application and if given, open with tsp (taskspooler)
open() {
    eval "$2" "$1 $data >/dev/null 2>&1" &
}

# download file to tmp directory before open it
open_tmp() {
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
        notify-send "link handler [video]" "$data" \
            && open "$video" "tsp"
    ;;
    *mp3 \
        | *flac \
        | *opus)
        notify-send "link handler [audio]" "$data" \
            && open "$podcast" "tsp"
    ;;
    *jpg \
        | *jpe \
        | *jpeg \
        | *png \
        | *gif \
        | *webp)
        notify-send "link handler [picture]" "$data" \
            && open_tmp "$picture"
    ;;
    *pdf \
        | *ps \
        | *djvu \
        | *epub \
        | *cbr \
        | *cbz)
        notify-send "link handler [document]" "$data" \
            && open_tmp "$document"
    ;;
    *torrent \
        | 'magnet\:'* \
        | *metalink \
        | *iso)
        notify-send "link handler [download]" "$data" \
            && open "$download"
    ;;
    *)
        if [ -f "$data" ]; then
            notify-send "link handler [edit]" "$data" \
                && open "$edit"
        else
            notify-send "link handler [web]" "$data" \
                && open "$web"
        fi
    ;;
esac
