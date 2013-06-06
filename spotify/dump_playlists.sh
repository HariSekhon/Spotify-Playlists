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

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$srcdir" || { echo "Failed to cd to '$srcdir'"; exit 1; }
total_playlists=0
total_tracks=0

# territory is currently broken
#spotify_program="spotify-lookup.pl --wait --retries 10 --mark-local --territory GB"
spotify_program="spotify-lookup.pl --wait --retries 10 --mark-local"

excluded_file(){
    local filename="$1"
    [ -d "$filename" ] && return 0
    shopt -s nocasematch
    [[ "$filename" =~ .*\.sh ]] && return 0
    [[ "$filename" =~ .*\.pl ]] && return 0
    [[ "$filename" =~ .*\.txt ]] && return 0
    [[ "$filename" =~ .*todo.* ]] && return 0
    [[ "$filename" =~ .*tocheck.* ]] && return 0
    for y in tmp TODO; do
        [ "$filename" = "$y" ] && return 0
    done
    shopt -s nocasematch
    return 1
}

normalize_playlist(){
    local playlist="$1"
    local normalized_playlist="$(dirname "$playlist")/.$(basename "$playlist")"
    echo "creating normalized playlist ../$normalized_playlist"
    ./normalize_tracknames.pl "../$playlist" > "../$normalized_playlist"
    playlist_wc="$(wc -l < "../$playlist" | awk '{print $1}')"
    normalized_playlist_wc="$(wc -l < "../$normalized_playlist" | awk '{print $1}')"
    [ "$playlist_wc" = "$normalized_playlist_wc" ] || { echo "ERROR: playlist vs normalized have mismatching line counts ($playlist_wc vs $normalized_playlist_wc)"; exit 1; }
    echo "normalized playlist created"
}

normalize_filename(){
    local playlist="${1#$srcdir/}"
    echo "$playlist"
}

dump_playlist(){
    local playlist="$(normalize_filename "$playlist")"
    #excluded_file "$playlist" && return 1
    [ -f "$playlist" ] || { echo "File not found: $playlist"; return 1; }
    let total_playlists+=1
    let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    spotify_lookup="$spotify_program $verbose -f $playlist $no_locking -s $speed_up $retries"
    playlist_dumpfile="../$(dirname "$playlist")/$(basename "$playlist")"
    if grep -qxFi "$playlist" "playlists_unordered.txt"; then
        output="$($spotify_lookup)"
        returncode=$?
        echo "$output" | sort -f > "$playlist_dumpfile"
        [ $returncode -eq 0 ] || { echo "ERROR: $output"; return 1; }
    else
        $spotify_lookup > "$playlist_dumpfile"
        returncode=$?
        [ $returncode -eq 0 ] || { echo "$output"; return 1; }
    fi
    echo "Wrote ../$playlist"
    normalize_playlist "$playlist"
    echo
    echo
}

dump_playlists(){
    local playlists=""
    for playlist in $@; do
        #excluded_file "$playlist" && continue
        [ -f "$playlist" ] || { echo "File not found: $playlist"; exit 1; }
        playlists="${playlists},${playlist}"
        let total_playlists+=1
        #let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    done
    playlists=${playlists#,}
    playlists=${playlists%,}
    $spotify_program -w "../" -v -v -f "$playlists" $no_locking --speed-up $speed_up # use in office for 4 DIPs ;)
    echo "$total_playlists playlists fetched"
    ls "$srcdir/../"[[:digit:]]* | grep '^[[:digit:]]*$' | while read playlist; do mv -v "$srcdir/../$playlist" "$srcdir/blacklists/"; done
    "$srcdir/../generate_normalized_playlists.sh"
    echo
    echo
}

usage(){
    cat <<EOF
${0##*/} [ -e ] [ -s ] [ -a ] playlist1 playlist2 ...

-a  Dump playlists all at the same time (shows total progress)
-e  Dump everything found in $srcdir
-r  Retries
-s  Speed up by a factor of 4 (use behind 4 IP DIP at work). Automatically enabled if on 10.1 or 10.2 networks at work
EOF
    exit 1
}

start=$(date +%s)
playlists=""
speed_up=1
all=0
everything=0
newer_than_dump=0
no_locking=""
retries=""
verbose="-vv"
until [ $# -lt 1 ]; do
    case $1 in
        -e) everything=1
            ;;
            # TODO: add support for newer than only here
        -n) newer_than_dump=1
            ;;
--no-locking) no_locking="--no-locking"
            ;;
        -s) speed_up=4
            ;;
        -r) [ -n "${2:-}" ] || usage
            retries="-r $2"
            shift
            ;;
        -a) let all+=1
            ;;
        -v) verbose="$verbose -v"
            ;;
        -*) usage
            ;;
         *) playlists="$playlists $1"
            ;;
    esac
    shift
done

# I'm not behind my 4 DIP GigE connection at SM any more :(
#if ifconfig | awk '/inet/ {print $2}' | grep -q "10\.[12]\."; then
#    speed_up=4
#fi

if [ "$everything" -ge 1 ]; then
    for x in * blacklists/*; do
        excluded_file "$x" && continue
        playlists="$playlists $(normalize_filename "$x")"
    done
elif [ -z "$playlists" ]; then
    for x in $(sed 's/#.*$//;/^[[:space:]]*$/d' playlists_ordered.txt playlists_unordered.txt); do
        playlists="$playlists $(normalize_filename "$x")"
    done
fi

if [ "$all" -ge 1 ]; then
    dump_playlists "$playlists"
    # Sort playlist that we want sorted
    for playlist in $playlists; do
        playlist="$(normalize_filename "$playlist")"
        if grep -qxFi "$playlist" "playlists_unordered.txt"; then
            sort -f < "../$playlist" > "../$playlist.tmp" && mv -f "../$playlist.tmp" "../$playlist"
        fi
    done
    echo "Sorted playlists"
    echo
    echo
    for playlist in $playlists; do
        playlist="$(normalize_filename "$playlist")"
        normalize_playlist "$playlist"
    done
else
    for playlist in $playlists; do
        playlist="$(normalize_filename "$playlist")"
        dump_playlist "$playlist" || exit
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed $total_playlists playlists, $total_tracks tracks in $total_secs secs"
