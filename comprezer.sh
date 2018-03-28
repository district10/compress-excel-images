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
    printf "... "
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
    while (( `cat "$1" | wc -c` > ${IMGSIZE:-4000000} )); do
        _mogrify "$1"
    done
}

function pic_minify() {
    printf "processing %s..." "$1"
    IMG="${1%.*}_minified.${1##*.}"
    _minify "$1" "$IMG" && _mogrify_until "$IMG" && mv "$IMG" "$1"
    printf "done\n"
}

function minify_all_pics() {
    for i in `find . \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -size +${IMGSIZE:-4000000}`; do
        pic_minify "$i"
    done
}

function full_path() {
    echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
}

function success() {
    echo '
                                 _
            __ _  ___   ___   __| |
           / _` |/ _ \ / _ \ / _` |
          | (_| | (_) | (_) | (_| |
           \__, |\___/ \___/ \__,_|
           |___/
    '
}

function fail() {
    echo '
              _               _
             | |__   __ _  __| |
             | "_ \ / _` |/ _` |
             | |_) | (_| | (_| |
             |_.__/ \__,_|\__,_|
    '
}

function comprezer() {
    ls -alh "$1" || exit
    echo all image files inside "$1" will be compressed so its filesize less than ${IMGSIZE:-4000000} bytes
    SRC=`full_path "$1"`
    D="${SRC%.*}_______compressed.${SRC##*.}"
    DST="${2:-${D}}"
    DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`
    TMP="input.xlsx"
    echo creating workspace $DIR...
    (cp "$1" "$DIR/$TMP" && cd "$DIR" && unzip -q $TMP && rm $TMP  && minify_all_pics && zip -r "$TMP" *) && cp "$DIR/$TMP" $DST && success || fail
    echo before: `ls -alh "$SRC"` && echo after : `ls -alh "$DST"`
}
