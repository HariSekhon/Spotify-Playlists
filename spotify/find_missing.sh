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
    local current_playlist="$1"
    local grand_playlists="${@:2}"
    #[ -f "$current_playlist" ] || { echo "Current playlist file not found: $current_playlist"; exit 1; }
    #for grand_playlst in $grand_playlists; do
    #    [ -f "$grand_playlist" ] || { echo "Grand playlist file not found: $grand_playlist"; exit 1; }
    #done
    echo "* Missing tracks in $current_playlist: (not found in "$grand_playlists")" >&2
    local uris_not_found=$(while read uri || [ -n "$uri" ]; do
        [ $quiet -eq 0 -a $verbose -le 1 ] && echo -n "." >&2
        #echo "reading uri: $uri" >&2
        if grep -qixF "$uri" ${@:2}; then
            echo "$uri"
        fi
    done < "$current_playlist"
    )
    [ $quiet -eq 0 -a $verbose -eq 0 ] && echo -n "  " >&2
    echo ">>> $(grep -v "^[[:space:]]*$" <<< "$uris_not_found" | wc -l | awk '{print $1}') / $(grep -v "^[[:space:]]*$" < "$current_playlist" | wc -l | awk '{print $1}') URIs not found"
    #[ $quiet -eq 0 -a $verbose -eq 0 ] && echo >&2
    if [ $nolookup -eq 0 -a $verbose -ge 1 -a "$tracks_not_found" != "$(cat $current_playlist)" ]; then
        echo
        while read uri; do
            if ! grep -qiFx "$uri" <<< "$tracks_not_found"; then
                track_name="$($spotify_lookup <<< "$uri")"
                if [ -z "$track_name" ]; then
                    echo "ERROR blank track name returned by $spotify_lookup for uri '$uri'" >&2
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
        done < "$current_playlist"
    fi >&2
    local tracks_not_found=$(
    echo "$uris_not_found" |
    grep -v "^[[:space:]]*$" |
    while read uri; do
        if [ $nolookup -eq 0 ]; then
            # don't need to pushd we won't be popd-ing
            cd "$srcdir/.." >&2
            [ $quiet -eq 0 -a $verbose -le 1 ] && echo -n "=" >&2
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
            track_name="$("$srcdir/normalize_trackname.pl" <<< "$track_name")"
            #echo "checking track name '$track_name'" >&2
            matches="$(grep -iF "$track_name" $grand_playlists 2>/dev/null | sed 's/^[^:]*://' | sort -u | head -n 20 | tr '\n' ',' | sed 's/,$//' )"
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
    if [ -n "$tracks_not_found" ]; then
        [ $quiet -eq 0 -a $verbose -eq 0 ] && echo -n "  " >&2
        echo ">>> $(wc -l <<< "$tracks_not_found" | awk '{print $1}') / $(wc -l <<< "$uris_not_found" | awk '{print $1}') Tracks not found"
        #[ $quiet -eq 0 -a $verbose -eq 0 ] && echo >&2
        if [ `uname` = Darwin ]; then
            local clipboard=pbcopy
        elif [ `uname` = Linux ]; then
            local clipboard=xclip
        else
            local clipboard=cat
        fi
        {
        if [ $notranslate -eq 1 ]; then
            echo "$tracks_not_found"
        else
            echo "$tracks_not_found" | $spotify_lookup
        fi
        } | tee /dev/stderr | $clipboard
        echo -e "\nTracks Not Found: $(wc -l <<< "$tracks_not_found" | awk '{print $1}') / $(wc -l < "$current_playlist" | awk '{print $1}')"
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

# If no current playlists, use a default list and add starred and current-hiphop and kiss
if [ -z "$current_playlists" ]; then
    current_playlists="$current_playlists_default starred"
    for x in current-hiphop kiss; do
        [ -f "$x" ] || { echo "Playlist not found: $x"; exit 1; }
    done
    find_missing "current-hiphop" "kiss"
fi
if [ -z "$grand_playlists" ]; then
    grand_playlists="$grand_playlists_default"
fi
if [ -n "$additional_grand_playlists" ]; then
    grand_playlists="$grand_playlists $additional_grand_playlists"
fi
# Check the playlists we're checking aren't in the list of playlists to be checked
for x in $current_playlists; do
    for y in $grand_playlists; do
        if [ "$x" = "$y" ]; then
            echo "Playlist '$x' cannot be in both current and grand playlists! "
            exit 1
        fi
    done
done
# Check the files exist for the current and grand playlists
for x in $current_playlists $grand_playlists; do
    [ -f "$x" ] || { echo "Playlist file not found: $x"; exit 1; }
done
for x in $current_playlists; do
    find_missing $x "$grand_playlists"
done
