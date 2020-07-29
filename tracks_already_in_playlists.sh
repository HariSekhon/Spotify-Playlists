#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-24 18:54:56 +0100 (Fri, 24 Jul 2020)
#
#  https://github.com/harisekhon/spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds Tracks exactly by URIs that already exist in my major playlists

Checks each URI in the given playlist file against the local offline files backup

This is useful for deleting them from TODO playlists, saving tonnes of time (combine with spotify_delete_from_playlist.sh)

For massive 8772 track TODO playlists this took 305 seconds, operating at 28.76 track URIs checked per second across all core playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_file> [<playlist_file2> ...]"

help_usage "$@"

min_args 1 "$@"

for filename; do
    if ! [ -f "$filename" ]; then
        die "Error: file not found '$filename'"
    fi
done

# if the tracks are in any of these playlists then print them out
# cannot put private/ prefix due to ambiguity with converting slashes to unicode names, instead I infer paths in next step
core_playlists="
Blacklist
My Shazam Tracks
Upbeat & Sexual Pop
Bounce to the Rhythm
Best R&B
Best Pop
Best Rock
Best Motown / Funk / Boogie / Groove / Soul
Chill
Soft
Sensual
Love Songs
Songs About Sex
Bad Boy Gets Down
Smooth
Smooth Hip-Hop
Elite Hip-Hop with Attitude
Jamaican / Reggae / Riddim
Grime
Club
Disco!
Electronica
Electro-Funk
Motown / Funk / Boogie / Groove / Soul
Jazz / Easy Listening / Lounge / Coffee Shops
Hip-Hop/R&B/Reggae/Grooves/Vibes
Rock / Metal / Indie / Alternative
Dance/Pop/House/Trance/DnB/Electronica/Gym
Workout / Dance / Trance / DnB / Energy / Beats
Workout Hip-Hop (Aggressive)
Trance / Dance - Best of
Classics / Decades Gone By
The 80s - The Greatest Decade in Human History!
Classical
Starred
"

core_playlists="$("$srcdir/bash-tools/spotify_playlist_to_filename.sh" <<< "$core_playlists")"

# find whether they're in top level or private subdirectory
core_spotify_playlists="$(< <(
    while read -r playlist; do
        [ -z "$playlist" ] && continue
        if [ -f "$srcdir/spotify/$playlist" ]; then
            echo "\"$srcdir/spotify/$playlist\""
        elif [ -f "$srcdir/private/spotify/$playlist" ]; then
            echo "\"$srcdir/private/spotify/$playlist\""
        else
            die "playlist not found: $playlist"
        fi
    done <<< "$core_playlists"
    )
)"

core_playlists="$(< <(
    while read -r playlist; do
        [ -z "$playlist" ] && continue
        if [ -f "$srcdir/$playlist" ]; then
            echo "\"$srcdir/$playlist\""
        elif [ -f "$srcdir/private/$playlist" ]; then
            echo "\"$srcdir/private/$playlist\""
        else
            die "playlist not found: $playlist"
        fi
    done <<< "$core_playlists"
    )
)"

find_duplicate_URIs(){
    local spotify_filename="$1"
    validate_spotify_uri "$(head -n 1 "$spotify_filename")" >/dev/null
    while read -r uri; do
        # more efficient to constructing doing this in one pass per URI rather than cartesian product
        #while read -r playlist; do
        #    [ -z "$playlist" ] && continue
        #    if grep -Fxq "$uri" "$playlist"; then
        #        echo "$uri"
        #        break
        #    fi
        #done <<< "$core_playlists"
        eval grep -Fxh "\"$uri\"" "$(tr '\n' ' ' <<< "$core_spotify_playlists")" | uniq || :
    done < "$spotify_filename"
}

is_track_in_core_playlists(){
    eval grep -Fqx "\"${1//\"/\\\"}\"" "$(tr '\n' ' ' <<< "$core_playlists")"
}

find_duplicate_URIs_by_track_name(){
    local filename="$1"
    #local spotify_filename="${filename%/*}/spotify/${filename##*/}"
    local spotify_filename="$2"
    # shellcheck disable=SC2094
    while read -r track_name; do
        if is_track_in_core_playlists "$track_name"; then
            grep -Fxhn "$track_name" "$filename" |
            sed 's/:.*$//' |
            while read -r track_position; do
                sed -n "${track_position}p" "$spotify_filename"
            done || :
        fi
    done < "$filename"
}

find_duplicate_tracks_URIs(){
    local track_filename="$1"
    local spotify_filename="$2"
    {
        find_duplicate_URIs "$spotify_filename"
        find_duplicate_URIs_by_track_name "$track_filename" "$spotify_filename"
    } |
    sort -u
}

for filename; do
    if [[ "$filename" =~ /spotify/ ]]; then
        spotify_filename="$filename"
        track_filename="${spotify_filename//spotify\/}"
    else
        track_filename="$filename"
        spotify_filename="${filename%/*}/spotify/${filename##*/}"
    fi
    find_duplicate_tracks_URIs "$track_filename" "$spotify_filename"
done
