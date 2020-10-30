#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-10-30T23:08:29+0100

# config
web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="tsp $TERMINAL -e mpv --no-audio-display"
video="tsp mpv --really-quiet"
picture="sxiv -q -a -s w"
document="$READER"
download="$TERMINAL -e terminal_wrapper.sh aria2c"

tmp="/tmp/link_handler"
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
    [--tmpdelete] = delete folder $tmp recursive
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

    tmp           = $tmp
    tmp_readable  = $tmp_readable
    tmp_download  = $tmp_download"

uri="$1"

# if no uri/file/setting is given, exit the script
[ -z "$uri" ] \
    && printf "%s\n" "$help" \
    && exit 1

# open in application with/-out tmp file
open() {
    case "$1" in
        "tmp")
            mkdir -p "$tmp"

            if [ "$3" = "readable" ]; then
                extension="html"
            else
                extension="${uri##*.}"
            fi

            tmp_file=$(mktemp "$tmp/open_tmp_XXXXXX" --suffix=".$extension")

            if [ "$3" = "readable" ]; then
                $tmp_readable "$2" > "$tmp_file" \
                    && "$web" "$tmp_file"
            else
                $tmp_download "$uri" > "$tmp_file" \
                    && $2 "$tmp_file"
            fi
            ;;
        *)
            $1 "$uri"
            ;;
    esac
}

case "$uri" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --readable)
        [ -n "$2" ] \
            && notify-send \
                "link handler - open link readable" \
                "$2" \
            && open tmp "$2" "readable"
        ;;
    --tmpdelete)
        [ -d "$tmp" ] \
            && notify-send \
                "link handler - delete tmp files" \
                "quantity: $(find $tmp -type f | wc -l)" \
            && rm -rf "$tmp"
        ;;
    *.mkv | *.MKV \
        | *.mp4 | *.MP4 \
        | *.webm | *.WEBM \
        | *'youtube.com/watch'* \
        | *'youtube.com/playlist'* \
        | *'youtu.be'*)
            notify-send \
                "link handler - add video to taskspooler" \
                "$uri"
            open "$video"
            ;;
    *.mp3 | *.MP3 \
        | *.ogg | *.OGG \
        | *.flac | *.FLAC \
        | *.opus | *OPUS)
            notify-send \
                "link handler - add audio to taskspooler" \
                "$uri"
            open "$podcast"
            ;;
    *.jpg | *.JPG \
        | *.jpe | *.JPE \
        | *.jpeg | *.JPEG \
        | *.png | *.PNG \
        | *.gif | *.GIF \
        | *.webp | *.WEBP)
            notify-send \
                "link handler - open picture" \
                "$uri"
            open tmp "$picture"
            ;;
    *.pdf | *.PDF \
        | *.ps | *.PS \
        | *.djvu | *.DJVU \
        | *.epub | *.EPUB \
        | *.cbr | *.CBR \
        | *.cbz | *.CBZ)
            notify-send \
                "link handler - open document" \
                "$uri"
            open tmp "$document"
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
