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
cd "$srcdir" || { echo "failed to cd to '$srcdir'"; exit 1; }

current_playlists_default="
starred
hangout-rnb
hangout-poprock
current-hiphop
current
fitness-first
workout
chill
"

grand_playlists_default="
kiss
dance
rock
"

spotify_lookup=spotify-lookup.pl

find_missing(){
    echo "* Missing tracks in $1: (not found in "$2")"
    tmp=$(
    while read line; do
        grep -qixF "$line" $2 ||
            echo "$line"
    done < "$1" |
    while read line; do
        pushd .. >/dev/null
        track_name="$(spotify-lookup.pl "$line")"
        grep -qixF "$track_name" $2 2>/dev/null ||
            echo "$line"
    done
    )
    # This is because we can't have 2 instance of spotify-lookup.pl running at the same time
    if [ -n "$tmp" ]; then
        echo "$tmp" | $spotify_lookup
    fi
    echo
    echo
}

current_playlists=""
grand_playlists=""
nolookup=0
while [ $# -gt 0 ]; do
    case $1 in
        -nolookup)  spotify_lookup=cat
                    ;;
               -g)  grand_playlists="$grand_playlists ${2:-}"
                    shift
                    ;;
                *)  current_playlists="$current_playlists $1"
                    ;;
    esac
    shift
done

if [ -z "$current_playlists" ]; then
    current_playlists="$current_playlists_default"
    find_missing "starred" "$grand_playlists_default"
    find_missing "starred" "$grand_playlists_default classics-archive love"
    find_missing "current-hiphop" "kiss"
fi
if [ -z "$grand_playlists" ]; then
    grand_playlists="$grand_playlists_default"
fi
for x in $current_playlists; do
    find_missing $x "$grand_playlists"
done
