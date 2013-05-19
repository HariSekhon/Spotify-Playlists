#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:14:36 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || { echo "Failed to cd to '$srcdir'"; exit 1; }
playlists_unordered="$(sed 's/#.*//' < "playlists_unordered.txt")"
playlists_ordered="$(sed 's/#.*//' < "playlists_ordered.txt")"
#inspiration
#rocky
#dt8-trance

uname_s=`uname -s`
if [ "$uname_s" = "Linux" ]; then
    which xsel &>/dev/null || { echo "ERROR: xsel was not found in \$PATH"; exit 1; }
    dump_clipboard(){
        xsel --clipboard | tr ' ' '\n'
        echo
    }
elif [ "$uname_s" = "Darwin" ]; then
    which pbcopy &>/dev/null || { echo "ERROR: pbcopy was not found in \$PATH"; exit 1; }
    dump_clipboard(){
        pbpaste
    }
else
    echo "ERROR: didn't detect system as either Linux or Apple (Darwin), don't know how to dump clipboard"
    exit 1
fi

end_newline(){
    echo >> "$1"
    grep -v "^[[:space:]]*$" < "$1" > "$1.tmpnl"
    mv "$1.tmpnl" "$1"
}

convert_spotify_uri_http(){
    perl -pi -e 's/^spotify:track:/http:\/\/open.spotify.com\/track\//' "$1"
}

paste_playlist(){
    dump_clipboard > "$1"
    end_newline "$1"
    convert_spotify_url_http "$1"
}

paste_ordered(){
    read -p "Ordered Paste $1: (hit enter when ready)" &&
    paste_playlist "$1"
    rm -vf "$1.tmp"
    echo
    ./find_dups.sh "$1"
    echo
    echo
}

paste_unordered(){
    read -p "Paste $1: (hit enter when ready)" &&
    paste_playlist "$1"
    sort -f < "$1" > "$1.tmpsort" &&
        mv "$1.tmpsort" "$1"
    rm -vf "$1.tmp" "$1.tmpsort"
    echo
    ./find_dups.sh "$1"
    echo
    echo
}

usage(){
    echo "${0##*/} [ playlist1 playlist2 playlist3 ... ]

Pastes the output of the clipboard straight in to the given files. If no files are given then it reads the playlists_unordered.txt and playlists_ordered.txt files in the same directory as this script and uses those as the list of playlist files
"
    exit 1
}

for x in $*; do
    case $x in
        -*) usage
    esac
done

if [ -n "$1" ]; then
#    if [ -n "$2" ]; then
#        paste_nosort "$1"
#    else
#        paste_sort "$1"
#    fi
    for x in $*; do
        if grep -qxiF "$x" "playlists_unordered.txt"; then
            paste_unordered "$x"
        else
            paste_ordered "$x"
        fi
    done
else
    for x in $playlists_ordered;   do paste_ordered   "$x"; done
    for x in $playlists_unordered; do paste_unordered "$x"; done
fi
