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

function _torgb() {
    identify -format "%r %f\n" "$1"
    COLOR=`identify -format %r "$1" | sed 's/[^ ]* //'`
    printf "\tconverting %s from colorspace %s to RGB..." "$1" "$COLOR"
    mogrify -colorspace RGB "$1"
    printf " done\n"
}

function pic_minify() {
    printf "\tprocessing %s..." "$1"
    SIZE0=`_filesize "$1"`
    IMG="${1%.*}_minified.${1##*.}"
    _minify "$1" "$IMG"; _mogrify_until "$IMG" && mv "$IMG" "$1"
    SIZE1=`_filesize "$1"`
    printf " done (image reduced to \e[1;35m%s bytes = %s - %s\e[m)\n" `echo $(($SIZE0 - $SIZE1)) | _bytes` `echo $SIZE0 | _bytes` `echo $SIZE1 | _bytes`
}

function minify_all_pics() {
    for i in xl/media/*; do
        identify -format %r "$i" | grep -e '^DirectClass \(Gray\|RGB\|sRGB\)' > /dev/null || _torgb "$i"
    done
    identify -ping -format "%w %f\n" xl/media/* | grep -E "\d{4}" | sed  "s/^.* /xl\/media\//" 2>/dev/null | while read img; do
        printf "\tresizing %s..." "$img"
        mogrify -resize 1000x1000 "$img"
        printf " done\n"
    done
    SZ=`_imgsize_threshold`
    find xl/media -size +${SZ}c | while read img; do
        identify "$img" > /dev/null && pic_minify "$img"
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

function _bytes() {
    sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta'
}

function comprezer() {
    if [ -z "$1" ]; then _usage; return; fi
    printf "all image files inside $1 will be compressed so its filesize less than \e[1;35m$(_imgsize_threshold | _bytes) bytes\e[m\n"
    SRC=`full_path "$1"`
    D="${SRC%.*}_______compressed.${SRC##*.}"
    DST="${2:-${D}}"
    DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
    TMP="input.xlsx"
    echo creating workspace $DIR...
    (cp "$1" "$DIR/$TMP" && cd "$DIR" && unzip -q $TMP && rm $TMP  && minify_all_pics && zip -q -r "$TMP" *) && cp "$DIR/$TMP" $DST
    SIZE0=`_filesize "$SRC"`
    SIZE1=`_filesize "$DST"`
    printf "reduced \n\t%s (%s bytes) to\n\t\e[1;35m %s (%s bytes) by %s bytes\e[m\n" "$SRC" `echo $SIZE0 | _bytes` "$DST" `echo $SIZE1 | _bytes` `echo $(($SIZE0 - $SIZE1)) | _bytes`
}
