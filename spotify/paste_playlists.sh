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
cd "$srcdir" || exit 1;
playlists_sort="$(sed 's/#.*//' < "playlists_sort.txt")"
playlists_nosort="$(sed 's/#.*//' < "playlists_nosort.txt")"
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

paste_nosort(){
    read -p "Ordered Paste $1: (hit enter when ready)" && dump_clipboard > "$1.tmp"; echo >> "$1.tmp"; grep -v "^[[:space:]]*$" < "$1.tmp" > "$1"; rm -f "$1.tmp"; echo; ./find_dups.sh "$1"; echo; echo
}

paste_sort(){
    read -p "Paste $1: (hit enter when ready)" && dump_clipboard > "$1.tmp"; echo >> "$1.tmp"; grep -v "^[[:space:]]*$" < "$1" > "$1.tmp"; sort -f < "$1.tmp" > "$1"; rm -f "$1.tmp"; echo; ./find_dups.sh "$1"; echo; echo
}

usage(){
    echo "${0##*/} [ playlist1 playlist2 playlist3 ... ]

Pastes the output of the clipboard straight in to the given files. If no files are given then it reads the playlists_sort.txt and playlists_nosort.txt files in the same directory as this script and uses those as the list of playlist files
"
    exit 1
}

for x in $@; do
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
    for x in $@; do
        if grep -qxiF "$x" "playlists_sort.txt"; then
            paste_sort "$x"
        else
            paste_nosort "$x"
        fi
    done
else
    for x in $playlists_nosort; do paste_nosort "$x"; done
    for x in $playlists_sort;   do paste_sort   "$x"; done
fi
