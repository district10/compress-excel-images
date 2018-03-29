function _minify() {
    convert \
        -strip \
        -interlace Plane \
        -gaussian-blur 0.05 \
        -filter Lanczos \
        -quality 85% \
        "$1" "$2"
}

function _mogrify() {
    printf " ..."
    mogrify \
        -strip \
        -interlace Plane \
        -gaussian-blur 0.05 \
        -filter Lanczos \
        -quality 85% \
        -resize 80% \
        "$1"
}

function _mogrify_until() {
    while (( `_filesize "$1"` > `_imgsize_threshold` )); do
        _mogrify "$1"
    done
}

function _filesize() {
    cat "$1" | wc -c
}

function pic_minify() {
    printf "processing %s..." "$1"
    SIZE0=`_filesize "$1"`
    IMG="${1%.*}_minified.${1##*.}"
    _minify "$1" "$IMG"; _mogrify_until "$IMG" && mv "$IMG" "$1"
    SIZE1=`_filesize "$1"`
    printf "done (image reduced by \e[1;35m%s bytes = %s - %s\e[m)\n" $(($SIZE0 - $SIZE1)) $SIZE0 $SIZE1
}

function minify_all_pics() {
    SZ=`_imgsize_threshold`
    find xl/media \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -size +${SZ}c | while read img; do
        pic_minify "$img"
    done
}

function full_path() {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

function _imgsize_threshold() {
    echo "${IMGSIZE:-4000000}" | tr -d ', '
}

function _usage() {
    echo '
        Usage:
            comprezer <input.xlsx> <optional-output.xlsx>                           # default threshould 4MB
            IMGSIZE=2000000; comprezer <input.xlsx> <optional-output.xlsx>          # customize threshould 2000000 bytes (~2MB)
            IMGSIZE=2,000,000; comprezer <input.xlsx> <optional-output.xlsx>        # more readable
    '
}

function comprezer() {
    if [ -z "$1" ]; then _usage; return; fi
    printf "all image files inside $1 will be compressed so its filesize less than \e[1;35m$(_imgsize_threshold) bytes\e[m\n"
    SRC=`full_path "$1"`
    D="${SRC%.*}_______compressed.${SRC##*.}"
    DST="${2:-${D}}"
    DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
    TMP="input.xlsx"
    # echo creating workspace $DIR...
    (cp "$1" "$DIR/$TMP" && cd "$DIR" && unzip -q $TMP && rm $TMP  && minify_all_pics && zip -q -r "$TMP" *) && cp "$DIR/$TMP" $DST
    SIZE0=`_filesize "$SRC"`
    SIZE1=`_filesize "$DST"`
    printf "reduced \n\t%s (%s bytes) to \n\t%s (%s bytes) by \n\t\e[1;35m %s bytes\e[m\n" "$SRC" $SIZE0 "$DST" $SIZE1 $(($SIZE0 - $SIZE1))
}
