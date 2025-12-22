#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-26 19:58:55 +0100 (Sun, 26 Jul 2020)
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

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes tracks from a given playlist that are already in other given local downloaded playlists

By default checks against my core playlists listed in:

    $srcdir/core_playlists.txt

Uses the offline URI playlists under spotify/ directory for speed since this is immensely faster
than fetching thousands of track URIs in batches of 100 from the Spotify API using the dynamic script:

    bash-tools/spotify/spotify_delete_from_playlist_if_in_other_playlists.sh

The playlist name must contain New Playlist / TODO / Discover / Backlog in the name for safety
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<playlist_name2> <playlist_name3> ...]"

help_usage "$@"

min_args 1 "$@"

export SPOTIFY_PRIVATE=1

# pre-load token once for deletions and URI=>track name resolving prompt to avoid repeated pop-ups
spotify_token

if [ -n "${SPOTIFY_DISABLE_SAFETY:-}" ]; then
    safety_regex=".*"
else
    safety_regex="New Playlist|TODO|Discover|Backlog"
fi

for playlist; do
    playlist_name="$playlist"
    if is_spotify_playlist_id "$playlist"; then
        timestamp "Resolving playlist ID to name"
        playlist_name="$("$bash_tools/spotify/spotify_playlist_id_to_name.sh" <<< "$playlist")"
    fi
    if ! [[ "$playlist_name" =~ $safety_regex ]]; then
        die "playlist name '$playlist_name' does not contain '$safety_regex', aborting for safety"
    fi
done

delete_tracks_from_playlist(){
    local playlist_name="$1"
    local track_uris_to_delete
    local count
    timestamp "Finding tracks in playlist \"$playlist_name\" that are already in other playlists"
    # finds songs by both URI match or name match
    track_uris_to_delete="$("$srcdir/tracks_already_in_playlists.sh" "$playlist_name" "$@" | sort -u)"
    if is_blank "$track_uris_to_delete"; then
        timestamp "No tracks found in existing playlists"
        return
    fi

    if has_terminal; then
        timestamp "Resolving track URIs to Names to list what we will delete:"
        echo

        "$bash_tools/spotify/spotify_uri_to_name.sh" <<< "$track_uris_to_delete"

        count="$(wc -l <<< "$track_uris_to_delete" | sed 's/[[:space:]]//g')"

        echo
        read -r -p "Are you happy to delete these $count tracks from the playlist '$playlist_name'? (y/N) " answer
        if ! [[ "$answer" =~ ^(y|yes) ]]; then
            die "Aborting..."
        fi
    fi

    echo
    timestamp "Deleting tracks already in core playlists from playlist: $playlist"
    "$bash_tools/spotify/spotify_delete_from_playlist.sh" "$playlist_name" <<< "$track_uris_to_delete"
    echo
}

for playlist; do
    delete_tracks_from_playlist "$playlist"
done
