#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/newsboat
# date:       2020-04-29T11:09:37+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv --no-audio-display"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

data="$1"

# if no url/file given exit the application
[ -z "$data" ] && {
    notify-send "link handler" "no url/file given, exit..."
    exit
}

# open in application and if given, open with tsp (taskspooler)
open() {
    eval "$2" "$1 $data >/dev/null 2>&1" &
}

# download files to tmp directory before open it
open_tmp() {
    curl -sL "$data" >"/tmp/$(printf "%s" "$data" | sed "s/.*\///")" \
    && eval "$1 /tmp/$(printf "%s" "$data" | sed "s/.*\///") >/dev/null 2>&1" &
}

# shellcheck disable=SC1001
case "$data" in
    *mkv | *mp4 | *webm | *youtube.com/watch* | *youtube.com/playlist* | *youtu.be*)
        notify-send "link handler" "open url in video player:\n$data" \
            && open "$video" "tsp"
    ;;
    *mp3 | *flac | *opus)
        notify-send "link handler" "open url in audio player:\n$data" \
            && open "$podcast" "tsp"
    ;;
    *jpg | *jpe | *jpeg | *png | *gif | *webp)
        notify-send "link handler" "open url in picture viewer:\n$data" \
            && open_tmp "$picture"
    ;;
    *pdf | *ps | *djvu | *epub | *cbr | *cbz)
        notify-send "link handler" "open url in document reader:\n$data" \
            && open_tmp "$document"
    ;;
    *torrent | magnet\:* | *metalink | *iso)
        notify-send "link handler" "open url in downloader:\n$data" \
            && open "$download"
    ;;
    *)
        if [ -f "$data" ]; then
            notify-send "link handler" "open url in editor:\n$data" \
                && open "$edit"
        else
            notify-send "link handler" "open url in browser:\n$data" \
                && open "$web"
        fi
    ;;
esac
