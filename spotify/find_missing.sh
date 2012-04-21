#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-15 20:37:10 +0100 (Sun, 15 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))

current_playlists="
starred
hangout-rnb
jay-z
current-hiphop
current
fitness-first
workout
"

grand_playlists="
kiss
dance
rock
"

find_missing(){
    echo "* Missing tracks in $1: (not found in "$2")"
    while read line; do
        grep -q "^$line$" $2 ||
            echo "$line"
    done < "$1" |
    spotify-lookup.pl | sort -f
    echo
    echo
}

if [ -n "$1" ]; then
    current_playlists=$@
fi
for x in $current_playlists; do
    find_missing $x "$grand_playlists"
done

find_missing "current-hiphop" "kiss"
