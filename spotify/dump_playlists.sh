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
    if grep -qxFi "$playlist" "$srcdir/playlists_sorted.txt"; then
        spotify-lookup.pl -v -f "$playlist" -s $speed_up | sort -f > "../$playlist"
    else
        spotify-lookup.pl -v -f "$playlist" -s $speed_up > "../$playlist"
    fi
    echo "Wrote ../$playlist"
    echo
    echo
}

dump_playlists(){
    local playlists=""
    for playlist in $@; do
        excluded_file "$playlist" && continue
        [ -f "$playlist" ] || { echo "File not found: $playlist"; exit 1; }
        playlists="${playlists},${playlist}"
        let total_playlists+=1
        let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    done
    playlists=${playlists#,}
    playlists=${playlists%,}
    spotify-lookup.pl -w "$srcdir/.." -v -f "$playlists" --speed-up $speed_up # use in office for 4 DIPs ;)
#    if grep -qxFi "$playlist" "$srcdir/playlists_sorted.txt"; then
#        spotify-lookup.pl -v -f "$playlist" | sort -f > "../$playlist"
#    else
#        spotify-lookup.pl -v -f "$playlist" > "../$playlist"
#    fi
#    echo "Wrote ../$playlist"
    echo
    echo
}

start=$(date +%s)
playlists=""
speed_up=1
all=0
until [ $# -lt 1 ]; do
    case $1 in
        -s) speed_up=4
            ;;
        -a) let all+=1
            ;;
         *) playlists="$playlists $1"
            ;;
    esac
    shift
done

if [ "$all" -ge 1 ]; then
    for x in $(sed 's/#.*$//;/^[[:space:]]*$/d' playlists_sorted.txt playlists_unsorted.txt); do
        excluded_file "$x" && continue
        playlists="$playlists $x"
    done
    dump_playlists "$playlists"
    # Sort playlist that we want sorted
    for playlist in $playlists; do
        if grep -qxFi "$playlist" "playlists_sorted.txt"; then
            sort -f < "../$playlist" > "../$playlist.tmp" && mv -f "../$playlist.tmp" "../$playlist"
        fi
    done
    echo "Sorted playlists"
elif [ -n "$playlists" ]; then
    for x in $playlists; do
        dump_playlist "$x"
    done
else
    for x in $(sed 's/#.*$//;/^[[:space:]]*$/d' playlists_sorted.txt playlists_unsorted.txt); do
        excluded_file "$x" && continue
        dump_playlist "$x"
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed $total_playlists playlists, $total_tracks tracks in $total_secs secs"
