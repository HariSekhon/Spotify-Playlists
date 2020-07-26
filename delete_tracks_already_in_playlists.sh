#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-26 19:58:55 +0100 (Sun, 26 Jul 2020)
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
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes tracks from a given playlist that are already in my core playlists

The playlist must be have 'TODO' in the name for safety
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<playlist_name> ...]"

help_usage "$@"

min_args 1 "$@"

for playlist; do
    if ! [[ "$playlist" =~ TODO ]]; then
        die "playlist name does not contain 'TODO', aborting for safety"
    fi
done

delete_tracks_from_playlist(){
    tracks_to_delete="$("$srcdir/tracks_already_in_playlists.sh" "$playlist")"

    "$srcdir/bash-tools/spotify_uri_to_name.sh" <<< "$tracks_to_delete"

    playlist="${playlist##*/}"

    echo
    read -r -p "Are you happy to delete these tracks from the playlist '$playlist'? " answer
    if ! [[ "$answer" =~ ^(y|yes) ]]; then
        die "Aborting..."
    fi

    echo
    "$srcdir/bash-tools/spotify_delete_from_playlist.sh" "$playlist" <<< "$tracks_to_delete"
    echo
}

for playlist; do
    delete_tracks_from_playlist "$playlist"
done
