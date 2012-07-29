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

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
classics-archive
classical
love
chill
jazz
"

spotify_lookup=spotify-lookup.pl

find_missing(){
    echo "* Missing tracks in $1: (not found in "${2# }")" >&2
    tmp=$(
    while read line; do
        grep -qixF "$line" ${@:2} ||
            echo "$line"
    done < "$1" |
    while read line; do
        if [ $nolookup -eq 0 ]; then
            # don't need to pushd we won't be popd-ing
            cd "$srcdir/.." >&2
            [ $verbose -gt 0 ] && echo -n "resolving/checking $track => " >&2
            track_name="$(spotify-lookup.pl <<< "$line")"
            [ $verbose -gt 0 ] && echo "$track_name" >&2
            # Remove - Radio Edit etc...
            # Remove ^The from artist name
            track_name="$(perl -pne 's/^The //i; s/ - \(?(?:\d{4}\s+)?(?:(?:Original )?Radio|(?:Digital )?Re-?master(?:ed)?|Single|Album|Uncut|Explicit|Mix|Original (?:Mix|Version)|Amended Album|Edit|UK Radio|Clean|Re-edit)\s.*$//i' <<< "$track_name")"
            #echo "checking track name '$track_name'" >&2
            if grep -qixF "$track_name" ${@:2} 2>/dev/null; then
                echo "already got '$track_name'" >&2
            else
                echo "$line"
            fi
        else
            echo "$line"
        fi
    done
    )
    # This is because we can't have 2 instance of spotify-lookup.pl running at the same time
    if [ -n "$tmp" ]; then
        if [ $notranslate -eq 1 ]; then
            echo "$tmp"
        else
            echo "$tmp" | $spotify_lookup
        fi
    fi
    echo
    echo
}

usage(){
    cat <<EOF
${0##*/} [-g] [-nolookup] playlist1 playlist2

-s -spotify-uri         Output Spotify URIs for pasting back in to spotify   
-n -nolookup            Don't translate at all, don't use spotify-lookup.pl to check artist - song (weakens matching. Only use when spotify-lookup.pl is broken). Also enables -spotify-uri
-g -grand-playlists     Playlists to check against
-a --aditional-grand-playlists Additional playlists to check on top of default list: $(tr '\n' ' ' <<< "$grand_playlists_default")
EOF
    exit 1
}

current_playlists=""
grand_playlists=""
additional_grand_playlists=""
nolookup=0
notranslate=0
verbose=0
while [ $# -gt 0 ]; do
    case $1 in
           --nolookup)  nolookup=1; notranslate=1
                        ;;
     -s|--spotify-uri)  notranslate=1
                        ;;
-a|-additional-grand-playlists)  additional_grand_playlists="${additional_grand_playlists} ${2:-}"
                        shift
                        ;;
 -g|--grand-playlists)  grand_playlists="$grand_playlists ${2:-}"
                        shift
                        ;;
                   -v)  let verbose+=1
                        ;;
                   -*)  usage
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
if [ -n "$additional_grand_playlists" ]; then
    grand_playlists="$grand_playlists $additional_grand_playlists"
fi
for x in $current_playlists; do
    find_missing $x "$grand_playlists"
done
