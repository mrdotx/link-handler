#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-11-18T13:53:09+0100

# config
web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="tsp $TERMINAL -e mpv --no-audio-display"
video="tsp mpv --really-quiet"
picture="sxiv -q -a -s w"
document="$READER"
download="$TERMINAL -e terminal_wrapper.sh aria2c"

tmp_folder="/tmp/link_handler"
tmp_readable="python -W ignore -m readability.readability -u"
tmp_download="curl -sL"

# help
script=$(basename "$0")
help="$script [-h/--help] -- script to open links on basis of extensions
  Usage:
    $script [--readable/--tmpdelete] [uri]

  Settings:
    [--readable]  = make the html content readable with python readability-lxml
                    (Mozilla's Readability library)
    [--tmpdelete] = delete folder $tmp_folder recursive
    [uri]         = uniform resource identifier

  Examples:
    $script suckless.org
    $script https://raw.githubusercontent.com/mrdotx/dotfiles/master/screenshot_monitor2.jpg
    $script --readable suckless.org
    $script --tmpdelete

  Config:
    web           = $web
    edit          = $edit
    podcast       = $podcast
    video         = $video
    picture       = $picture
    document      = $document
    download      = $download

    tmp_folder    = $tmp_folder
    tmp_readable  = $tmp_readable
    tmp_download  = $tmp_download"

# if no uri/file/setting is given, exit the script
[ -z "$1" ] \
    && printf "%s\n" "$help" \
    && exit 1

uri="$1"
uri_lower="$(printf "%s" "$1" | tr '[:upper:]' '[:lower:]')"

# open with/-out tmp file or readable
open() {
    case "$1" in
        "--readable")
            mkdir -p "$tmp_folder"
            tmp_file=$(mktemp "$tmp_folder/open_tmp_XXXXXX" --suffix=".html")

            $tmp_readable "$2" > "$tmp_file" \
                && "$web" "$tmp_file"
            ;;
        "--tmp")
            mkdir -p "$tmp_folder"
            tmp_file=$(mktemp "$tmp_folder/open_tmp_XXXXXX" --suffix=".${uri_lower##*.}")

            $tmp_download "$uri" > "$tmp_file" \
                && $2 "$tmp_file"
            ;;
        *)
            $1 "$uri"
            ;;
    esac
}

case "$uri_lower" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --readable)
        [ -n "$2" ] \
            && notify-send \
                "link handler - open link readable" \
                "$2" \
            && open "$uri_lower" "$2"
        ;;
    --tmpdelete)
        [ -d "$tmp_folder" ] \
            && notify-send \
                "link handler - delete tmp files" \
                "quantity: $(find $tmp_folder -type f | wc -l)" \
            && rm -rf "$tmp_folder"
        ;;
    *.mkv | *.mp4 | *.webm | *'youtube.com/watch'* | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send \
                "link handler - add video to taskspooler" \
                "$uri"
            open "$video"
            ;;
    *.mp3 | *.ogg | *.flac | *.opus)
            notify-send \
                "link handler - add audio to taskspooler" \
                "$uri"
            open "$podcast"
            ;;
    *.jpg | *.jpe | *.jpeg | *.png | *.gif | *.webp)
            notify-send \
                "link handler - open picture" \
                "$uri"
            open --tmp "$picture" &
            ;;
    *.pdf | *.ps | *.djvu | *.epub | *.cbr | *.cbz)
            notify-send \
                "link handler - open document" \
                "$uri"
            open --tmp "$document" &
            ;;
    *.torrent | 'magnet\:'* | *.metalink | *.iso | *.img | *.bin | *.tar \
        | *.tar.bz2 | *.tbz2 | *.tar.gz | *.tgz | *.tar.xz | *.txz | *.zip \
        | *.7z | *.rar)
            notify-send \
                "link handler - download file" \
                "$uri"
            open "$download"
            ;;
    *)
        if [ -f "$uri" ]; then
            notify-send \
                "link handler - edit file" \
                "$uri"
            open "$edit"
        else
            notify-send \
                "link handler - open link" \
                "$uri"
            open "$web"
        fi
        ;;
esac
