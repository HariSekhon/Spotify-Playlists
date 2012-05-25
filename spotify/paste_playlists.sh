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
playlists_sorted="$(sed 's/#.*//' < "$srcdir/playlists_sorted.txt")"
playlists_unsorted="$(sed 's/#.*//' < "$srcdir/playlists_unsorted.txt")"
#inspiration
#rocky
#dt8-trance

paste_nosort(){
    echo "Ordered Paste $1:"; cat > "$1"; ./find_dups.sh "$1"; echo; echo
}

paste_sort(){
    echo "Paste $1:"; cat | sort -f > "$1"; ./find_dups.sh "$1"; echo; echo
}
if [ -n "$1" ]; then
#    if [ -n "$2" ]; then
#        paste_nosort "$1"
#    else
#        paste_sort "$1"
#    fi
    for x in $@; do
        if grep -qxiF "$x" "$srcdir/playlists_sorted.txt"; then
            paste_sort "$x"
        else
            paste_nosort "$x"
        fi
    done
else
    for x in $playlists_unsorted; do paste_nosort "$x"; done
    for x in $playlists_sorted;   do paste_sort   "$x"; done
fi
