#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:09:18 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1
total_playlists=0
total_tracks=0

excluded_file(){
    [ -d "$1" ] && return 0
    shopt -s nocasematch
    [[ "$1" =~ .*\.sh ]] && return 0
    [[ "$1" = .*\.txt ]] && return 0
    [[ "$x" =~ .*todo.* ]] && return 0
    [[ "$x" =~ .*tocheck.* ]] && return 0
    for y in tmp TODO; do
        [ "$x" = "$y" ] && return 0
    done
    shopt -s nocasematch
    return 1
}

dump_playlist(){
    local playlist="$1"
    excluded_file "$playlist" && return 1
    [ -f "$playlist" ] || { echo "File not found: $playlist"; return 1; }
    let total_playlists+=1
    let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    if grep -qxFi "$playlist" "$srcdir/sorted_playlists.txt"; then
        spotify-lookup.pl -v -f "$playlist" | sort -f > "../$playlist"
    else
        spotify-lookup.pl -v -f "$playlist" > "../$playlist"
    fi
    echo "Wrote ../$playlist"
    echo
    echo
}

start=$(date +%s)
if [ -n "$1" ]; then
    for x in $@; do
        dump_playlist "$x"
    done
else
    for x in *; do
        excluded_file "$x" && continue
        dump_playlist "$x"
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed $total_playlists playlists, $total_tracks tracks in $total_secs secs"
