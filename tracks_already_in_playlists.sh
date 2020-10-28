#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: "Discover Backlog"
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
Finds Tracks already exist in the major playlist files saved here via

1. exact URI match
2. Artist - TrackName exact match (may be different URI copies but should be exactly the same song)

Gets the URIs of a given playlist and hecks each one against the local offline playlist files backup

This is useful for deleting them from TODO playlists, saving tonnes of time (combine with spotify_delete_from_playlist.sh)

For massive 8772 track TODO playlists this took 305 seconds, operating at 28.76 track URIs checked per second across all core playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name>"

help_usage "$@"

min_args 1 "$@"

# allow filtering private playlists
export SPOTIFY_PRIVATE=1

spotify_token

core_playlists="${SPOTIFY_CORE_PLAYLISTS:-$(sed 's/^#.*//; /^[[:space:]]*$/d' "$srcdir/core_playlists.txt" | "$srcdir/bash-tools/spotify_playlist_to_filename.sh")}"

# auto-resolve each spotify playlist's path to either ./spotify/ or ./private/spotify/
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

# auto-resolve each playlist's path to either ./ or ./private
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

filter_duplicate_URIs(){
    #validate_spotify_uri "$(head -n 1 "$spotify_filename")" >/dev/null
    eval grep -Fxh -f /dev/stdin "$(tr '\n' ' ' <<< "$core_spotify_playlists")" || :
}

filter_tracks_in_core_playlists(){
    # would return the wrong results, the line numbers of the local playlists not the line numbers from the targeted playlist
    #eval grep -Fxhn -f /dev/stdin "$(tr '\n' ' ' <<< "$core_playlists")" || :
    local index=1
    while read -r track; do
        if is_track_in_core_playlists "$track"; then
            # uri variable is inherited from parent function filter_duplicate_URIs_by_track_name
            sed -n "${index}p" <<< "$uris"
        fi
        ((index+=1))
    done
}

is_track_in_core_playlists(){
    eval grep -Fxq -f /dev/stdin "$(tr '\n' ' ' <<< "$core_playlists")" <<< "$@"
}

filter_duplicate_URIs_by_track_name(){
    local uris
    local tracks
    uris="$(cat)"

    # efficient but dangerous, if spotify_uri_to_name.sh fails to return and the order is off, we'd end up deleting the wrong tracks
    #paste <("$srcdir/bash-tools/spotify_uri_to_name.sh" <<< "$input") <(cat <<< "$input") |

    tracks="$("$srcdir/bash-tools/spotify_uri_to_name.sh" <<< "$uris" | grep -v '^[[:space:]]*$')"

    # off by one due to occasional track with blank artist/track name fields, rely on exit code instead of this
    #if [ "$(wc -l <<< "$uris")" != "$(wc -l <<< "$tracks")" ]; then
    #    die "ERROR: failed to resolve all URIs for track name comparisons"
    #fi

    # XXX: wrong results, takes lines from the local files which might be in the wrong order to the current online playlist
    #local lines_tracks
    #lines_tracks="$(filter_tracks_in_core_playlists <<< "$tracks")"
    #sed_print_lines="$(sed 's/:.*/p;/' <<< "$lines_tracks")"
    #sed -n "$sed_print_lines" <<< "$uris"
    #lines_tracks="$(filter_tracks_in_core_playlists <<< "$tracks")"

    filter_tracks_in_core_playlists <<< "$tracks"
}

# works fine, but slow
filter_duplicate_URIs_by_track_name_slow(){
    while read -r track_uri; do
        track_name="$("$srcdir/bash-tools/spotify_uri_to_name.sh" <<< "$track_uri")"
        if is_track_in_core_playlists "$track_name"; then
            echo "$track_uri"
        fi
    done
}

find_duplicate_tracks_URIs(){
    local playlist_name="$1"
    "$srcdir/bash-tools/spotify_playlist_tracks_uri.sh" "$playlist_name" |
    tee >/dev/null \
        >(filter_duplicate_URIs) \
        >(filter_duplicate_URIs_by_track_name) |
    sort -u
}

for playlist_name; do
    find_duplicate_tracks_URIs "$playlist_name"
done
