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
    local filename="$1"
    [ -d "$filename" ] && return 0
    shopt -s nocasematch
    [[ "$filename" =~ .*\.sh ]] && return 0
    [[ "$filename" =~ .*\.txt ]] && return 0
    [[ "$filename" =~ .*todo.* ]] && return 0
    [[ "$filename" =~ .*tocheck.* ]] && return 0
    for y in tmp TODO; do
        [ "$filename" = "$y" ] && return 0
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
everything=0
until [ $# -lt 1 ]; do
    case $1 in
        -e) everything=1
            ;;
        -s) speed_up=4
            ;;
        -a) let all+=1
            ;;
         *) playlists="$playlists $1"
            ;;
    esac
    shift
done

if [ "$everything" -ge 1 ]; then
    for x in $(ls); do
        playlists="$playlists $x"
    done
else
    for x in $(sed 's/#.*$//;/^[[:space:]]*$/d' playlists_sorted.txt playlists_unsorted.txt); do
        playlists="$playlists $x"
    done
fi
playlists2=""
for x in $playlists; do
    excluded_file "$x" && continue
    playlists2="$playlists $x"
done

if [ "$all" -ge 1 ]; then
    dump_playlists "$playlists2"
    # Sort playlist that we want sorted
    for playlist in $playlists2; do
        if grep -qxFi "$playlist" "playlists_sorted.txt"; then
            sort -f < "../$playlist" > "../$playlist.tmp" && mv -f "../$playlist.tmp" "../$playlist"
        fi
    done
    echo "Sorted playlists"
else
    for x in $playlists2; do
        dump_playlist "$x"
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed $total_playlists playlists, $total_tracks tracks in $total_secs secs"
