#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-08-27T11:04:11+0200

web="$TERMINAL -e $TERMINAL_BROWSER"
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
    *mkv | *MKV \
        | *mp4 | *MP4 \
        | *webm | *WEBM \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send "link handler - add video to taskspooler" "$input"
            open "$video" "tsp"
    ;;
    *mp3 | *MP3 \
        | *ogg | *OGG \
        | *flac | *FLAC \
        | *opus | *OPUS)
            notify-send "link handler - add audio to taskspooler" "$input"
            open "$podcast" "tsp"
    ;;
    *jpg | *JPG \
        | *jpe | *JPE \
        | *jpeg | *JPEG \
        | *png | *PNG \
        | *gif | *GIF \
        | *webp | *WEBP)
            notify-send "link handler - open picture" "$input"
            open_tmp "$picture"
    ;;
    *pdf | *PDF \
        | *ps | *PS \
        | *djvu | *DJVU \
        | *epub | *EPUB \
        | *cbr | *CBR \
        | *cbz | *CBZ)
            notify-send "link handler - open document" "$input"
            open_tmp "$document"
    ;;
    *torrent | *TORRENT \
        | 'magnet\:'* \
        | *metalink | *METALINK \
        | *iso | *ISO \
        | *tar | *TAR \
        | *tar.gz | *TAR.GZ | *tgz | *TGZ \
        | *zip | *ZIP \
        | *7z | *7Z \
        | *rar | *RAR)
            notify-send "link handler - download file" "$input"
            open "$download"
    ;;
    *)
        if [ -f "$input" ]; then
            notify-send "link handler - edit file" "$input"
            open "$edit"
        else
            notify-send "link handler - open link" "$input"
            readable -q "$input" > /tmp/newsboat.html && eval "$web" /tmp/newsboat.html &
        fi
    ;;
esac
