#!/bin/sh

# path:   /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author: klassiker [mrdotx]
# github: https://github.com/mrdotx/link-handler
# date:   2022-06-21T20:30:18+0200

# config
web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="tsp $TERMINAL -e mpv --no-audio-display"
video="tsp mpv --really-quiet"
picture="nsxiv -q -a -s w"
document="$READER"
download="$TERMINAL -e terminal_wrapper.sh aria2c.sh"

tmp_download="curl -fsS "
tmp_readable="python -W ignore -m readability.readability -u"

# help
script=$(basename "$0")
help="$script [-h/--help] -- script to open links on basis of extensions
  Usage:
    $script [--clipboard] [--readable] [uri]

  Settings:
    [--clipboard] = open uri from clipboard
    [--readable]  = make the html content readable with python readability-lxml
                    (Mozilla's Readability library)
    [uri]         = uniform resource identifier

  Examples:
    $script suckless.org
    $script https://raw.githubusercontent.com/mrdotx/dotfiles/master/screenshot_monitor1.png
    $script --clipboard
    $script --readable suckless.org

  Config:
    web           = $web
    edit          = $edit
    podcast       = $podcast
    video         = $video
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

case "$uri_lower" in
    --readable)
        [ -n "$2" ] \
            && notify-send \
                -u normal \
                "link handler - open link readable" \
                "$2"
            open "$uri_lower" "$2"
        ;;
    *.mkv \
        | *.mp4 \
        | *.webm \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send \
                -u normal \
                "link handler - add video to taskspooler" \
                "$uri"
            open "$video"
            ;;
    *.mp3 \
        | *.ogg \
        | *.flac \
        | *.opus)
            notify-send \
                -u normal \
                "link handler - add audio to taskspooler" \
                "$uri"
            open "$podcast"
            ;;
    *.jpg \
        | *.jpe \
        | *.jpeg \
        | *.png \
        | *.gif \
        | *.webp)
            notify-send \
                -u normal \
                "link handler - open picture" \
                "$uri"
            open --tmp "$picture" &
            ;;
    *.pdf \
        | *.ps \
        | *.djvu \
        | *.epub \
        | *.cbr \
        | *.cbz)
            notify-send \
                -u normal \
                "link handler - open document" \
                "$uri"
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
            notify-send \
                -u normal \
                "link handler - download file" \
                "$uri"
            open "$download"
            ;;
    *)
        if [ -f "$uri" ]; then
            notify-send \
                -u normal \
                "link handler - edit file" \
                "$uri"
            open "$edit"
        else
            notify-send \
                -u normal \
                "link handler - open link" \
                "$uri"
            open "$web"
        fi
        ;;
esac
