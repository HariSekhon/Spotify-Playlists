#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: "Discover Backlog"
#
#  Author: Hari Sekhon
#  Date: 2020-07-24 18:54:56 +0100 (Fri, 24 Jul 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

core_playlists="$srcdir/core_playlists.txt"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds Tracks already exist in the major playlist files saved here via

1. exact URI match
2. Artist - TrackName exact match (may be different URI copies but is exactly the same song)

Gets the URIs of a given playlist and checks each one against the local offline playlist file backups because this is
immensely faster than pulling all the tracks from massive core playlists dynamically

This is useful for deleting them from TODO playlists, saving tonnes of time (combine with spotify_delete_from_playlist.sh)

Used by adjacent delete_tracks_in_blacklists.sh

For massive 8772 track TODO playlists this took 305 seconds, operating at 28.76 track URIs checked per second across all core playlists

Can optionally specify the playlists the check against using args, otherwise defaults to using the list at:

    $core_playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<only_if_in_this_playlist> <or_this_playlist> ...]"

help_usage "$@"

min_args 1 "$@"

playlist_name="$1"
shift || :

# allow filtering private playlists - we don't pull live playlists any more as files are faster
#export SPOTIFY_PRIVATE=1

# pre-load token for resolving URIs to tracks
spotify_token

# requires GNU grep to work, Mac's grep is buggy with use of -f
if is_mac; then
    grep(){
        command ggrep "$@"
    }
fi

if [ $# -gt 0 ]; then
    # format one file per line to normalize and align the input format with the core playlist for later use by functions the same way
    core_playlists="$(for arg; do echo "$arg"; done)"
else
    core_playlists="$(sed 's/^#.*//; /^[[:space:]]*$/d' "$core_playlists" | "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh")"
fi

# auto-resolve each spotify playlist's path to its file path under ./ or ./private
find_playlist_file(){
    local playlist_name="$1"
    local get_uri_file="${2:-}"  # any value to trigger this logic
    local resolved_file
    is_blank "$playlist_name" && return
    if [ -f "$srcdir/${get_uri_file:+spotify/}$playlist_name" ]; then
        resolved_file="$srcdir/${get_uri_file:+spotify/}$playlist_name"
    elif [ -f "$srcdir/private/${get_uri_file:+spotify/}$playlist_name" ]; then
        resolved_file="$srcdir/private/${get_uri_file:+spotify/}$playlist_name"
    else
        die "playlist not found: $playlist_name"
    fi
    log "using file: $resolved_file"
    echo "$resolved_file"
}
export -f find_playlist_file

# auto-resolve each spotify playlist's path to its URI download at either ./spotify/ or ./private/spotify/
core_spotify_playlists="$(< <(
    while read -r playlist_name; do
        find_playlist_file "$playlist_name" get_uri_file
    done <<< "$core_playlists"
    )
)"

# auto-resolve each playlist's path to either ./ or ./private
core_playlists="$(< <(
    while read -r playlist_name; do
        find_playlist_file "$playlist_name"
    done <<< "$core_playlists"
    )
)"

# XXX: pre-load all URIs and track names for performance - trading RAM for I/O
core_spotify_playlists_tracks_uri="$(
    while read -r playlist; do
        cat "$playlist"
    done <<< "$core_spotify_playlists" |
    sort -u
)"

core_playlists_tracks="$(
    while read -r playlist; do
        cat "$playlist"
    done <<< "$core_playlists" |
    "$srcdir/spotify-tools/normalize_tracknames.pl" |
    sort -u
)"

filter_duplicate_URIs(){
    #validate_spotify_uri "$(head -n 1 "$spotify_filename")" >/dev/null
    grep -Fxh -f /dev/stdin <(echo "$core_spotify_playlists_tracks_uri") || :
}

filter_tracks_in_core_playlists(){
    # would return the wrong results, the line numbers of the local playlists not the line numbers from the targeted playlist
    #eval grep -Fxhn -f /dev/stdin "$(tr '\n' ' ' <<< "$core_playlists")" || :
    #local index=1
    # slooow due to so much forking
    #while read -r track; do
    #    if is_track_in_core_playlists "$track"; then
    #        # uri variable is inherited from parent function filter_duplicate_URIs_by_track_name
    #        #sed -n "${index}p" <<< "$uris"
    #        echo "${index}p;"
    #    fi
    #    ((index+=1))
    #done |
    # requires GNU grep to work, Mac's grep is buggy
    grep -Fxn --color=no -f <(echo "$core_playlists_tracks") /dev/stdin |
    cut -f1 -d: |
    sort -u |
    sed '/^[[:space:]]*$/d; s/$/p;/g' |
    sed -n "$(cat)" <<< "$uris"  # uris is read from parent function filter_duplicate_URIs_by_track_name
}

# ok but slow
#is_track_in_core_playlists(){
#    grep -Fxq -f /dev/stdin <<< "$core_playlists_tracks"
#}

# works fine, but slower due to many calls of spotify_uri_to_name.sh (one per track URI)
#filter_duplicate_URIs_by_track_name_slow(){
#    while read -r track_uri; do
#        track_name="$("$srcdir/bash-tools/spotify/spotify_uri_to_name.sh" <<< "$track_uri")"
#        if is_track_in_core_playlists "$track_name"; then
#            echo "$track_uri"
#        fi
#    done
#}

filter_duplicate_URIs_by_track_name(){
    local uris
    local tracks
    uris="$(cat)"

    # efficient but dangerous, if spotify_uri_to_name.sh fails to return and the order is off, we'd end up deleting the wrong tracks
    #paste <("$srcdir/bash-tools/spotify/spotify_uri_to_name.sh" <<< "$input") <(cat <<< "$input") |

    tracks="$("$srcdir/bash-tools/spotify/spotify_uri_to_name.sh" <<< "$uris" |
              "$srcdir/spotify-tools/normalize_tracknames.pl")"

    if [ "$(wc -l <<< "$uris")" != "$(wc -l <<< "$tracks")" ]; then
        die "ERROR: failed to resolve all URIs for track name comparisons"
    fi

    filter_tracks_in_core_playlists <<< "$tracks"
}

find_duplicate_tracks_URIs(){
    local playlist_name="$1"
    local playlist_file
    playlist_file="$(find_playlist_file "$playlist_name" get_uri_file)"
    #"$srcdir/bash-tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_name" |
    cat "$playlist_file" |
    tee >/dev/null \
        >(filter_duplicate_URIs) \
        >(filter_duplicate_URIs_by_track_name) |
    sort -u
}

find_duplicate_tracks_URIs "$playlist_name"
