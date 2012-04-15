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
sorted_files="
current_mix
kiss
dance
rock
electronica
workout
fitness-first
chill
jazz
love
classics-archive
classical
"
#inspiration
#rocky
#dt8-trance
unsorted_files="
hangout-rnb
jay-z
"

paste_nosort(){
    echo "Ordered Paste $1:"; cat > "$1"; ./find_dups.sh "$1"; echo; echo
}

paste_sort(){
    echo "Paste $1:"; cat | sort -f > "$1"; ./find_dups.sh "$1"; echo; echo
}
if [ -n "$1" ]; then
    if [ -n "$2" ]; then
        paste_nosort "$1"
    else
        paste_sort "$1"
    fi
else
    for x in $sorted_files; do paste_sort "$x"; done
    for x in $unsorted_files; do paste_nosort "$x"; done
fi
