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
Deletes tracks from a given playlist that are already in Blacklist playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<playlist_name2> ...]"

help_usage "$@"

min_args 1 "$@"

export SPOTIFY_PRIVATE=1

# pre-load token once for deletions and URI=>track name resolving prompt to avoid repeated pop-ups
spotify_token

# assume we are reasonably up to date since these tracks have a large stock to flow ratio and
# we can always run a partial backup of just the latest Blacklist playlist manually if we want a fresher list
#"$srcdir/backup_private.sh" $("$srcdir/bash-tools/spotify_playlists.sh" | grep -E '^Blacklist[[:digit:]]+$')

delete_blacklisted_tracks_from_playlist(){
    local playlist_name="$1"
    local track_uris_to_delete
    local count
    #track_uris_to_delete="$(grep -Fxhf "$playlist" "$srcdir/private/spotify/Blacklist"{,2,3} | sort -u)"
    # finds songs by both URI match or name match
    timestamp "Finding matching tracks from Blacklists"
    track_uris_to_delete="$("$srcdir/tracks_already_in_playlists.sh" "$playlist_name" Blacklist{,2,3})"
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
    timestamp "Deleting tracks in blacklists from playlist: $playlist"
    "$bash_tools/spotify/spotify_delete_from_playlist.sh" "$playlist_name" <<< "$track_uris_to_delete"
    echo
}

for playlist; do
    if [[ "$playlist" =~ Blacklist ]]; then
        warn "Cannot specify to delete from a Blacklist itself"
        continue
    fi
    delete_blacklisted_tracks_from_playlist "$playlist"
done
