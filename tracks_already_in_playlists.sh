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
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/bash-tools"

#if [ -d "$srcdir/../bash-tools" ]; then
#    bash_tools="$srcdir/../bash-tools"
#fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC1090,SC1091
. "$srcdir/scripts/lib/playlist-utils.sh"

core_playlists="$srcdir/scripts/core_playlists.txt"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds Tracks already exist in the major playlist files saved here via

1. Exact URI match
2. Artist - TrackName exact match (may be different URI copies but is exactly the same song)

Gets the URIs of a given playlist and checks each one against the local offline playlist file backups because this is
immensely faster than pulling all the tracks from massive core playlists dynamically via the Spotify API which is rate
limited and blocks excessive number of requests with HTTP 429 Too Many Requests 14 hour bans

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
    core_playlists="$(
        {
            sed 's/^#.*//; /^[[:space:]]*$/d' "$core_playlists" |
            awk '{$1=""; print}'

            sed 's/^#.*//; /^[[:space:]]*$/d' "$srcdir/private/spotify/playlists.txt" |
            awk '/Blacklist/{$1=""; print}'
        } |
        sort -u |
        "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh" |
        sed '/^[[:space:]]*$/d'
    )"
fi
is_blank "$core_playlists" && die "FAILED to load core playlist basenames"
log "

Core Playlist Basenames:

$core_playlists
"

# ============================================================================ #
timestamp "Resolving core playlist URI file paths"
# auto-resolve each spotify playlist's path to its URI download at either ./spotify/ or ./private/spotify/
core_spotify_playlists="$(
    sed '/^[[:space:]]*$/d' <(
    while read -r playlist_name; do
        if [ "${CLEANING_BLACKLISTS:-}" = 1 ] &&
           [[ "$playlist_name" =~ Blacklist ]]; then
            continue
        fi
        find_playlist_file "$playlist_name" get_uri_file
    done <<< "$core_playlists"
    )
)"
is_blank "$core_spotify_playlists" && die "FAILED to resolve core spotify playlist files"
log "

Core Spotify Playlists:

$core_spotify_playlists
"

# ============================================================================ #
timestamp "Resolving core playlist file paths"
# auto-resolve each playlist's path to either ./ or ./private
core_playlists="$(
    sed '/^[[:space:]]*$/d' <(
    while read -r playlist_name; do
        if [ "${CLEANING_BLACKLISTS:-}" = 1 ] &&
           [[ "$playlist_name" =~ Blacklist ]]; then
            continue
        fi
        find_playlist_file "$playlist_name"
    done <<< "$core_playlists"
    )
)"
is_blank "$core_playlists" && die "FAILED to load core playlists file list"
log "

Core Playlists:

$core_playlists
"

core_playlist_track_uris_tempfile="$(mktemp)"
core_playlist_tracks_tempfile="$(mktemp)"
duplicate_uris_tempfile="$(mktemp)"

trap_cmd "rm -f '$core_playlist_track_uris_tempfile' '$core_playlist_tracks_tempfile' '$duplicate_uris_tempfile'"

# ============================================================================ #
# XXX: pre-load all URIs and track names for performance - trading RAM for I/O
timestamp "Pre-loading all core playlist track URIs"
# Bash pipe was dying here trying to trade RAM for 100% CPU due 100,000 tracks, so use temp file instead
while read -r playlist; do
    #timestamp "Loading from playlist: $playlist"
    cat "$playlist"
done <<< "$core_spotify_playlists" |
sort -u > "$core_playlist_track_uris_tempfile"
num_track_uris="$(wc -l < "$core_playlist_track_uris_tempfile" | sed 's/[[:space:]]//g')"
[ -s "$core_playlist_track_uris_tempfile" ] || die "FAILED to pre-load core playlist track URIs"
timestamp "Pre-loaded all core playlist track URIs: $num_track_uris"

# ============================================================================ #
timestamp "Pre-loading all core playlist tracks"
while read -r playlist; do
    #timestamp "Loading from playlist: $playlist"
    cat "$playlist"
done <<< "$core_playlists" |
"$srcdir/spotify-tools/normalize_tracknames.pl" |
sort -u > "$core_playlist_tracks_tempfile"
num_tracks="$(wc -l < "$core_playlist_tracks_tempfile" | sed 's/[[:space:]]//g')"
[ -s "$core_playlist_tracks_tempfile" ] || die "FAILED to pre-load core playlist tracks"
timestamp "Pre-loaded all core playlist tracks: $num_tracks"

# ============================================================================ #
filter_duplicate_URIs(){
    local playlist_uri_file="$1"
    #validate_spotify_uri "$(head -n 1 "$spotify_filename")" >/dev/null
    timestamp "Finding tracks in existing playlists by exact URI matches"
    # fast enough either way <= 0.1 secs
    #grep -Fxh -f "$core_playlist_track_uris_tempfile" "$playlist_uri_file" || :
    # faster because it loads -f file into RAM and then scans through big file once
    grep -Fxh -f "$playlist_uri_file" "$core_playlist_track_uris_tempfile" || :
    timestamp "Finished checking exact URI matches"
}

# ============================================================================ #
filter_tracks_in_core_playlists(){
    local playlist_uri_file="$1"
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
    timestamp "Finding tracks in existing playlists by exact name matches"
    # requires GNU grep to work, Mac's BSD grep is buggy
    # fast enough either way <= 0.1 secs
    # faster because it loads -f file into RAM and then scans through big file once
    #grep -Fxn --color=no -f /dev/stdin "$core_playlist_tracks_tempfile" |
    # BUT we need the order to get the line numbers correctly
    grep -Fxn --color=no -f "$core_playlist_tracks_tempfile" /dev/stdin |
    cut -f1 -d: |
    sort -u |
    sed '/^[[:space:]]*$/d; s/$/p;/g' |
    sed -n "$(cat)" < "$playlist_uri_file"
    timestamp "Finished checking exact name matches"
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

# ============================================================================ #
filter_duplicate_URIs_by_track_name(){
    local playlist_uri_file="$1"
    local tracks
    local num_tracks

    # efficient but dangerous, if spotify_uri_to_name.sh fails to return and the order is off, we'd end up deleting the wrong tracks
    #paste <("$srcdir/bash-tools/spotify/spotify_uri_to_name.sh" <<< "$input") <(cat <<< "$input") |

    num_tracks="$(wc -l < "$playlist_uri_file" | sed 's/[[:space:]]//g')"

    # XXX: because we need to return the track URIs to calling scripts and we cannot determine this from 'Artist - Track' names
    #      so we can't do the quicker cheaper cat'ing of the top level file for comparison here
    timestamp "Resolving $num_tracks track URIs to names and normalizing them for comparison to existing playlists (this is the most time expensive step)"
    # XXX: a single Spotify playlist can't be bigger than 10,000 tracks so this shouldn't overload bash pipe to need tempfile
    tracks="$(
        # optimization to not resolve URIs which we already know are duplicates
        # pre-filter them out and only resolve the rest for normalize name-based matching
        grep -Fxv -f "$duplicate_uris_tempfile" < "$playlist_uri_file" |
        "$srcdir/bash-tools/spotify/spotify_uri_to_name.sh" |
        "$srcdir/spotify-tools/normalize_tracknames.pl"
    )"

    # sanity check
    if [ "$(wc -l < "$playlist_uri_file" | sed 's/[[:space:]]//g')" != "$(wc -l <<< "$tracks" | sed 's/[[:space:]]//g')" ]; then
        die "ERROR: failed to resolve all URIs for track name comparisons"
    fi

    filter_tracks_in_core_playlists "$playlist_uri_file" <<< "$tracks"
    timestamp "Completed checking resolved URI to track names"
}

# ============================================================================ #
find_duplicate_tracks_URIs(){
    local playlist_name="$1"
    local playlist_uri_file
    playlist_uri_file="$(find_playlist_file "$playlist_name" get_uri_file)"
    #"$srcdir/bash-tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_name" |
    timestamp "Finding tracks in existing playlists for: $playlist_uri_file"
    {
        # don't parallelize this any more as filter_duplicate_URIs is fast enough
        # that this doesn't save time and only complicates the code
        #cat "$playlist_uri_file" |
        #tee /dev/null \
        #    >(filter_duplicate_URIs) \
        #    >(filter_duplicate_URIs_by_track_name) |

        filter_duplicate_URIs "$playlist_uri_file" | tee "$duplicate_uris_tempfile"
        num_duplicate_uris="$(wc -l < "$duplicate_uris_tempfile" | sed 's/[[:space:]]//g')"
        timestamp "Found $num_duplicate_uris duplicate URIs"
        filter_duplicate_URIs_by_track_name "$playlist_uri_file"
    } |
    sort -u
}

find_duplicate_tracks_URIs "$playlist_name"
timestamp "Completed finding tracks already in playlists in $SECONDS secs"
