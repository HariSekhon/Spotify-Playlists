#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-11-12 16:36:17 +0000 (Fri, 12 Nov 2021)
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
Loads tracks from any given user's public playlists to Discover Backlog playlist

You can find the Spotify username from the 'copy profile link' button in the Spotify app
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<spotify_username>"

help_usage "$@"

min_args 1 "$@"

username="$1"

export SPOTIFY_PRIVATE=1

spotify_token

"$srcdir/bash-tools/spotify/spotify_playlists.sh" "$username" |
while read -r playlist_id playlist_name; do
    timestamp "adding tracks from playlist '$playlist_name':"
    "$srcdir/bash-tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_id" |
    "$srcdir/bash-tools/spotify/spotify_add_to_playlist.sh" "Discover Backlog"
    echo
done
