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
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes tracks from a given playlist that are already in my core playlists

The playlist name must contain New Playlist / TODO / Discover / Backlog in the name for safety
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<playlist_name> ...]"

help_usage "$@"

min_args 1 "$@"

if [ -n "${SPOTIFY_DISABLE_SAFETY:-}" ]; then
    safety_regex=".*"
else
    safety_regex="New Playlist|TODO|Discover|Backlog"
fi

for playlist; do
    playlist_name="$playlist"
    if is_spotify_playlist_id "$playlist"; then
        playlist_name="$("$bash_tools/spotify/spotify_playlist_id_to_name.sh" <<< "$playlist")"
    fi
    if ! [[ "$playlist_name" =~ $safety_regex ]]; then
        die "playlist name '$playlist_name' does not contain '$safety_regex', aborting for safety"
    fi
done

delete_tracks_from_playlist(){
    local playlist_name="$1"
    local tracks_to_delete
    local count
    timestamp "Finding tracks in playlist \"$playlist_name\" that are already in other playlists"
    tracks_to_delete="$("$srcdir/tracks_already_in_playlists.sh" "$playlist_name")"
    if is_blank "$tracks_to_delete"; then
        timestamp "No tracks found in existing playlists"
        return
    fi

    if is_interactive; then
        "$bash_tools/spotify/spotify_uri_to_name.sh" <<< "$tracks_to_delete"

        count="$(wc -l <<< "$tracks_to_delete" | sed 's/[[:space:]]//g')"

        echo
        read -r -p "Are you happy to delete these $count tracks from the playlist '$playlist_name'? (y/N) " answer
        if ! [[ "$answer" =~ ^(y|yes) ]]; then
            die "Aborting..."
        fi
    fi

    echo
    "$bash_tools/spotify/spotify_delete_from_playlist.sh" "$playlist_name" <<< "$tracks_to_delete"
    echo
}

for playlist; do
    delete_tracks_from_playlist "$playlist"
done
