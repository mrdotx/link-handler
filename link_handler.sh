#!/bin/sh

# path:       /home/klassiker/.local/share/repos/link-handler/link_handler.sh
# author:     klassiker [mrdotx]
# github:     https://github.com/mrdotx/link-handler
# date:       2020-10-08T14:58:20+0200

web="$BROWSER"
edit="$TERMINAL -e $EDITOR"
podcast="$TERMINAL -e mpv"
video="mpv --really-quiet"
picture="sxiv -a -s f"
document="$READER"
download="$TERMINAL -e aria2c"

tmp="/tmp/link_handler"

check() {
    used_tools="
        tsp
        readable"

    printf "required tools marked with an X are installed\n"

    printf "%s\n" "$used_tools" | {
        while IFS= read -r line; do
            [ -n "$line" ] \
                && tool=$(printf "%s" "$line" | sed 's/ //g') \
                &&  if command -v "$tool" > /dev/null 2>&1; then
                        printf "      [X] %s\n" "$tool"
                    else
                        printf "      [ ] %s\n" "$tool"
                    fi
        done
    }
}

script=$(basename "$0")
help="$script [-h/--help] -- script to open links on basis of extensions
  Usage:
    $script [--readable/--tmpdelete] [uri]

  Settings:
    [--readable] = make the html content readable with readability-cli
                   (Mozilla's Readability library)
    [--tmpdelete]   = delete the tmp files created with this script
    [uri]        = uniform resource identifier

  Examples:
    $script suckless.org
    $script https://raw.githubusercontent.com/mrdotx/dotfiles/master/screenshot_monitor2.jpg
    $script --readable suckless.org
    $script --tmpdelete

  Programs:
    $(check)

    web = $web
    edit = $edit
    podcast = $podcast
    video = $video
    picture = $picture
    document = $document
    download = $download"

uri="$1"

# if no uri/file/setting is given, exit the script
[ -z "$uri" ] \
    && printf "%s\n" "$help" \
    && exit 1

# open in application and if given, open with tsp (taskspooler)
open() {
    eval "$2" "$1 '$uri' >/dev/null 2>&1" &
}

# save to tmp file and open in application
open_tmp() {
    mkdir -p "$tmp"

    if [ "$2" = "readable" ]; then
        extension="html"
    else
        extension="${uri##*.}"
    fi

    tmp_file=$(mktemp "$tmp/open_tmp_XXXXXX" --suffix=".$extension")

    if [ "$2" = "readable" ]; then
        readable -q "$1" > "$tmp_file" \
            && "$web" "$tmp_file" &
    else
        curl -sL "$uri" > "$tmp_file" \
            && $1 "$tmp_file" >/dev/null 2>&1 &
    fi
}

case "$uri" in
    -h | --help)
        printf "%s\n" "$help"
        ;;
    --readable)
       [ -n "$2" ] \
            && notify-send "link handler - open link readable" "$2" \
            && open_tmp "$2" "readable"
        ;;
    --tmpdelete)
        notify-send "link handler - delete tmp files" "quantity: $(find $tmp -type f | wc -l)"
        rm -rf "$tmp"
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
