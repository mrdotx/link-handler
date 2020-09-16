#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-09-16T08:22:17+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

tmp="/tmp/link_handler"
uri="$1"

script=$(basename "$0")
help="$script [-h/--help] -- script to open links on basis of extensions
  Usage:
    $script [--readable] [uri]

  Settings:
    [--readable] = make the html content readable with readability-cli
                   (Mozilla's Readability library)
    [uri]        = uniform resource identifier

  Examples:
    $script suckless.org
    $script --readable suckless.org

  Programms:
    web = $BROWSER
    edit = $TERMINAL -e $EDITOR
    podcast = $TERMINAL -e mpv --no-audio-display
    video = mpv --really-quiet
    picture = sxiv -a -s f
    document = $READER
    download = $TERMINAL -e aria2c

  Examples:
    $script suckless.org
    $script https://raw.githubusercontent.com/mrdotx/dotfiles/master/screenshot_monitor2.jpg
    $script --readable suckless.org"

mkdir -p "$tmp"

# if no uri/file/setting is given, exit the script
[ -z "$uri" ] \
    && printf "%s\n" "$help" \
    && exit 1

# open in application and if given, open with tsp (taskspooler)
open() {
    eval "$2" "$1 $uri >/dev/null 2>&1" &
}

# convert content with readable-cli before open it
open_readable() {
    tmp_file=$(mktemp $tmp/readable_XXXXXX --suffix=.html) \
        && readable -q "$1" > "$tmp_file" \
        && "$web" "$tmp_file" &
}

# download file to tmp directory before open it
open_tmp() {
    curl -sL "$uri" > "$tmp/$(printf "%s" "$uri" \
        | sed "s/.*\///")" \
        && eval "$1 $tmp/$(printf "%s" "$uri" \
        | sed "s/.*\///") >/dev/null 2>&1" &
}

case "$uri" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --readable)
       [ -n "$2" ] \
            && notify-send "link handler - open link readable" "$2" \
            && open_readable "$2"
        ;;
    *.mkv | *.MKV \
        | *.mp4 | *.MP4 \
        | *.webm | *.WEBM \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send "link handler - add video to taskspooler" "$uri"
            open "$video" "tsp"
            ;;
    *.mp3 | *.MP3 \
        | *.ogg | *.OGG \
        | *.flac | *.FLAC \
        | *.opus | *OPUS)
            notify-send "link handler - add audio to taskspooler" "$uri"
            open "$podcast" "tsp"
            ;;
    *.jpg | *.JPG \
        | *.jpe | *.JPE \
        | *.jpeg | *.JPEG \
        | *.png | *.PNG \
        | *.gif | *.GIF \
        | *.webp | *.WEBP)
            notify-send "link handler - open picture" "$uri"
            open_tmp "$picture"
            ;;
    *.pdf | *.PDF \
        | *.ps | *.PS \
        | *.djvu | *.DJVU \
        | *.epub | *.EPUB \
        | *.cbr | *.CBR \
        | *.cbz | *.CBZ)
            notify-send "link handler - open document" "$uri"
            open_tmp "$document"
            ;;
    *.torrent | *.TORRENT \
        | 'magnet\:'* \
        | *.metalink | *.METALINK \
        | *.iso | *.ISO \
        | *.img | *.IMG \
        | *.bin | *.BIN \
        | *.tar | *.TAR \
        | *.tar.bz2 | *.TAR.BZ2 | *.tbz2 | *.TBZ2 \
        | *.tar.gz | *.TAR.GZ | *.tgz | *.TGZ \
        | *.tar.xz | *.TAR.XZ | *.txz | *.TXZ \
        | *.zip | *.ZIP \
        | *.7z | *.7Z \
        | *.rar | *.RAR)
            notify-send "link handler - download file" "$uri"
            open "$download"
            ;;
    *)
        if [ -f "$uri" ]; then
            notify-send "link handler - edit file" "$uri"
            open "$edit"
        else
            notify-send "link handler - open link" "$uri"
            open "$web"
        fi
        ;;
esac
