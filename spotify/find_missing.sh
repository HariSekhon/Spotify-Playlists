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

for x in $current_playlists; do
    echo "* Missing tracks in $x: (not found in "$grand_playlists")"
    while read line; do
        grep -q "^$line$" $grand_playlists ||
            echo "$line"
    done < "$x" |
    spotify-lookup.pl | sort -f
    echo
    echo
done
