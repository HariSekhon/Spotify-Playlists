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

#echo "OBSOLETE, DO NOT USE THIS, Use find-missing-tracks.pl (on github) instead"
#exit 1

srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$srcdir" || { echo "failed to cd to '$srcdir'"; exit 1; }

current_playlists_default="$(sed 's/#.*//;/^[[:space:]]*$/d' $srcdir/playlists_current.txt)"
grand_playlists_default="$(sed 's/#.*//;/^[[:space:]]*$/d' $srcdir/playlists_grand.txt)"

find_missing(){
    echo "* Missing tracks in $1: (not found in "${2# }")" >&2
    uris_not_found=$(while read uri || [ -n "$uri" ]; do
        [ $quiet -eq 0 -a $verbose -eq 0 ] && echo -n "." >&2
        #echo "reading uri: $uri" >&2
        if grep -qixF "$uri" ${@:2}; then
            if [ $nolookup -eq 0 ]; then
                track_name="$($spotify_lookup <<< "$uri")"
                if [ -z "$track_name" ]; then
                    echo "ERROR blank track name returned by $spotify_lookup" >&2
                    echo "$uri"
                    continue
                fi
                if [ $verbose -ge 2 ]; then
                    echo "already got '$track_name'   <=  $uri" >&2
                elif [ $verbose -ge 1 ]; then
                    echo "already got '$track_name'" >&2
                fi
            else
                [ $verbose -ge 1 ] && echo "already got '$uri'" >&2
            fi >&2
        else
            echo "$uri"
        fi
    done < "$1"
    )
    [ $quiet -eq 0 -a $verbose -eq 0 ] && echo >&2
    tmp=$(
    echo "$uris_not_found" |
    while read uri; do
        if [ $nolookup -eq 0 ]; then
            # don't need to pushd we won't be popd-ing
            cd "$srcdir/.." >&2
            [ $quiet -eq 0 -a $verbose -eq 0 ] && echo -n ":" >&2
            [ $verbose -ge 2 ] && echo -n "resolving/checking $track => " >&2
            track_name="$($spotify_lookup <<< "$uri")"
            if [ -z "$track_name" ]; then
                echo "ERROR blank track name returned by $spotify_lookup" >&2
                echo "$uri"
                continue
            fi
            [ $verbose -ge 3 ] && echo "$track_name" >&2
            # Remove - Radio Edit etc...
            # Remove ^The from artist name
            track_name="$(perl -pne 's/^The //i;
            s/ (?:- (?:\(|")?|\()(?:(?:\d{1,4}"?|New|US|UK)\s+)?(?:Radio|(?:Digital )?Re-?master(?:ed)?|Single|Album|Amended|Main|Uncut|(?:Mainstream |Re-)?Edit|Explicit|Clean|Mix|Original|Bonus Track|'"'"'?\w+ Version|(?:as )?made famous|theme from|from|Full length)([\s\)].*)?$//i;
            s/( - .+) - Live$/$1/i' <<< "$track_name")"
            #echo "checking track name '$track_name'" >&2
            matches="$(grep -iF "$track_name" ${@:2} 2>/dev/null | sed 's/^[^:]*://' | sort -u | head -n 20 | tr '\n' ',' | sed 's/,$//' )"
            if [ -n "$matches" ]; then
                if [ $verbose -ge 2 ]; then
                    echo "already got '$track_name' ($matches)" >&2
                elif [ $verbose -ge 1 ]; then
                    echo "already got '$track_name'" >&2
                fi
            else
                echo "$uri"
            fi
        else
            echo "$uri"
        fi
    done
    )
    # This is because we can't have 2 instance of spotify-lookup.pl running at the same time
    if [ -n "$tmp" ]; then
        [ $quiet -eq 0 -a $verbose -eq 0 ] && echo >&2
        if [ $notranslate -eq 1 ]; then
            echo "$tmp"
        else
            echo "$tmp" | $spotify_lookup
        fi
    fi
    echo >&2
    echo >&2
}

usage(){
    cat <<EOF
${0##*/} [-g] [-nolookup] playlist1 playlist2

-s --spotify-uri         Output Spotify URIs for pasting back in to spotify   
-n --nolookup            Don't translate at all, don't use spotify-lookup.pl to check artist - song (weakens matching. Only use when spotify-lookup.pl is broken). Also enables -spotify-uri
-g --grand-playlists     Playlists to check against
-a --aditional-grand-playlists Additional playlists to check on top of default list: $(tr '\n' ' ' <<< "$grand_playlists_default")
--no-locking             Set no locking on spotify-lookup.pl
-v --verbose             Increase verbosity level
-q --quiet               Quiet mode
EOF
    exit 1
}

current_playlists=""
grand_playlists=""
additional_grand_playlists=""
nolookup=0
notranslate=0
no_locking=""
verbose=0
quiet=0
while [ $# -gt 0 ]; do
    case $1 in
        -n|--nolookup)  nolookup=1; notranslate=1
                        ;;
     -s|--spotify-uri)  notranslate=1
                        ;;
-a|--additional-grand-playlists)  additional_grand_playlists="${additional_grand_playlists} ${2:-}"
                        shift
                        ;;
 -g|--grand-playlists)  grand_playlists="$grand_playlists ${2:-}"
                        shift
                        ;;
         --no-locking)  no_locking="--no-locking"
                        ;;
         -v|--verbose)  let verbose+=1
                        ;;
           -q|--quiet)  quiet=1
                        ;;
                   -*)  usage
                        ;;
                    *)  current_playlists="$current_playlists $1"
                        ;;
    esac
    shift
done

[ $quiet -eq 1 ] && verbose=0

spotify_lookup="spotify-lookup.pl $no_locking"

if [ -z "$current_playlists" ]; then
    current_playlists="$current_playlists_default"
    find_missing "starred" "$grand_playlists_default"
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
