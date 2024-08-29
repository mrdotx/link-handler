#!/bin/sh

# path:   /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/link-handler
# date:   2024-08-29T12:16:09+0200

# config
web="w3m.sh"
edit="$TERMINAL -e $EDITOR"
podcast="tsp $TERMINAL -e mpv"
video="tsp mpv --terminal=no"
iptv="mpv --terminal=no --script-opts=menu_playlist=1 --force-window"
picture="nsxiv --quiet --animate --scale-mode w"
document="zathura"
download="$TERMINAL -e terminal_wrapper.sh aria2c.sh"

tmp_download="curl -fsS "
tmp_readable="python -W ignore -m readability.readability -u"

# help
script=$(basename "$0")
help="$script [-h/--help] -- script to open links on basis of extensions
  Usage:
    $script [--clipboard/--readable] [uri]

  Settings:
    [--clipboard] = open uri from clipboard
    [--readable]  = make the html content readable with python readability-lxml
                    (Mozilla's Readability library)
    [uri]         = uniform resource identifier

  Examples:
    $script suckless.org
    $script https://raw.githubusercontent.com/mrdotx/dotfiles/master/screenshot.png
    $script --clipboard
    $script --readable suckless.org

  Config:
    web           = $web
    edit          = $edit
    podcast       = $podcast
    video         = $video
    iptv          = $iptv
    picture       = $picture
    document      = $document
    download      = $download

    tmp_download  = $tmp_download
    tmp_readable  = $tmp_readable"

case "$1" in
    -h | --help | '')
        printf "%s\n" "$help"
        [ -z "$1" ] \
            && exit 1
        exit 0
        ;;
    --clipboard)
        [ "$(command -v "xsel")" ] \
            && uri="$(xsel -n -o -b)"
        ;;
    *)
        uri="$1"
        ;;
esac

uri_lower="$(printf "%s" "$uri" | tr '[:upper:]' '[:lower:]')"

# notifications
notify() {
    notify-send \
        -u low \
        "link handler - $1" \
        "$2"
}

# open with/-out tmp file or readable
open() {
    open_tmp() {
        tmp_file=$(mktemp -t link_handler.XXXXXX --suffix=".$1")
            $2 "$3" > "$tmp_file" \
                && $4 "$tmp_file" \
                && rm -rf "$tmp_file"
    }

    case "$1" in
        "--readable")
            open_tmp "html" "$tmp_readable" "$2" "$web"
            ;;
        "--tmp")
            open_tmp "${uri_lower##*.}" "$tmp_download" "$uri" "$2"
            ;;
        *)
            $1 "$uri"
            ;;
    esac
}

# main
case "$uri_lower" in
    --readable)
        [ -n "$2" ] \
            && notify "open link readable" "$2"
            open "$uri_lower" "$2"
        ;;
    *.mp3 \
        | *.ogg \
        | *.flac \
        | *.opus)
            notify "add audio to taskspooler" "$uri"
            open "$podcast"
            ;;
    *.m3u \
        | *.m3u8)
            notify "open stream" "$uri"
            open "$iptv"
            ;;
    *.mkv \
        | *.mp4 \
        | *.webm \
        | rtsp://* \
        | *youtube.com/watch* \
        | *youtube.com/playlist* \
        | *youtu.be*)
            notify "add video to taskspooler" "$uri"
            open "$video"
            ;;
    *.jpg \
        | *.jpe \
        | *.jpeg \
        | *.png \
        | *.gif \
        | *.webp)
            notify "open picture" "$uri"
            open --tmp "$picture" &
            ;;
    *.pdf \
        | *.ps \
        | *.djvu \
        | *.epub \
        | *.cbr \
        | *.cbz)
            notify "open document" "$uri"
            open --tmp "$document" &
            ;;
    *.torrent \
        | 'magnet\:'* \
        | *.metalink \
        | *.iso \
        | *.img \
        | *.bin \
        | *.tar \
        | *.tar.bz2 \
        | *.tbz2 \
        | *.tar.gz \
        | *.tgz \
        | *.tar.xz \
        | *.txz \
        | *.zip \
        | *.7z \
        | *.rar)
            notify "download file" "$uri"
            open "$download"
            ;;
    *)
        if [ -f "$uri" ]; then
            notify "edit file" "$uri"
            open "$edit"
        else
            notify "open link" "$uri"
            open "$web"
        fi
        ;;
esac
