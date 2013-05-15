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

dump_playlist(){
    local playlist="$1"
    #excluded_file "$playlist" && return 1
    [ -f "$playlist" ] || { echo "File not found: $playlist"; return 1; }
    let total_playlists+=1
    let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    spotify_lookup="spotify-lookup.pl --wait $verbose -f $playlist $no_locking -s $speed_up $retries"
    if grep -qxFi "$playlist" "playlists_sort.txt"; then
        output="$($spotify_lookup)"
        returncode=$?
        echo "$output" | sort -f > "../$playlist"
        [ $returncode -eq 0 ] || { echo "ERROR: $output"; return 1; }
    else
        $spotify_lookup > "../$playlist"
        returncode=$?
        [ $returncode -eq 0 ] || { echo "$output"; return 1; }
    fi
    echo "Wrote ../$playlist"
    echo "creating normalized playlist ../.$playlist"
    ./normalize_tracknames.pl "../$playlist" > "../.$playlist"
    echo "normalized playlist created"
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
        let total_tracks+=$(wc -l "$playlist" | awk '{print $1}')
    done
    playlists=${playlists#,}
    playlists=${playlists%,}
    spotify-lookup.pl --wait -w "../`dirname $playlist`" -v -v -f "$playlists" $no_locking --speed-up $speed_up # use in office for 4 DIPs ;)
#    if grep -qxFi "$playlist" "playlists_sort.txt"; then
#        spotify-lookup.pl --wait -v -f "$playlist" | sort -f > "../$playlist"
#    else
#        spotify-lookup.pl --wait -v -f "$playlist" > "../$playlist"
#    fi
#    echo "Wrote ../$playlist"
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
    for x in *; do
        excluded_file "$x" && continue
        playlists="$playlists $x"
    done
elif [ -z "$playlists" ]; then
    for x in $(sed 's/#.*$//;/^[[:space:]]*$/d' playlists_nosort.txt playlists_sort.txt); do
        playlists="$playlists $x"
    done
fi

if [ "$all" -ge 1 ]; then
    dump_playlists "$playlists"
    # Sort playlist that we want sorted
    for playlist in $playlists; do
        if grep -qxFi "$playlist" "playlists_sort.txt"; then
            sort -f < "../$playlist" > "../$playlist.tmp" && mv -f "../$playlist.tmp" "../$playlist"
        fi
    done
    echo "Sorted playlists"
    echo
    echo
    for playlist in $playlists; do
        echo "creating normalized playlist ../.$playlist"
        ./normalize_tracknames.pl "../$playlist" > "../.$playlist"
        echo "normalized playlist created"
    done
else
    for x in $playlists; do
        dump_playlist "$x" || exit
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed $total_playlists playlists, $total_tracks tracks in $total_secs secs"
