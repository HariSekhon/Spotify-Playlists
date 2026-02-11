#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-20 23:24:12 -0500 (Tue, 20 Jan 2026)
#
#  https///github.com/HariSekhon/Spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

playlists="
215bzez43cnPzX1cFUNP17	Elite Favourites 💯😎
3iRkPfmGAPH9zOrOwPOibk	Favourites 💯 😎
0a89oThiwNzUZtJWF3NDwa	Hot Love 🍑 💦
64OO67Be8wOXn6STqHxexr	Upbeat & Sexual Pop 🍑 💦
5RR38VsaYbbgK9KQv2V7gv	Elite Hip-Hop with Attitude 😎
7isarHP3nVD7punZolUnYZ	Smooth Hip-Hop 😎
0DAPPqAeWuZrjge0LwYryS	Best Pop 🥳 🎉
5hHBAgEmYWkcMkWWSNrml7	Best R&B 😎
5YyD3L0oa0rVKUNREpEnww	Best Rock 🤘 🎸
"

# shellcheck disable=SC2034,SC2154
usage_description="
Count the top artists for some of my most popular playlists using spotify_playlist_top_artists.sh
from DevOps-Bash-tools repo (it's a submodule)

These are the playlists I currently care most about which we output metrics for:

$playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<playlist> <playlist2> ...]"

help_usage "$@"

#min_args 1 "$@"

spotify_token

process_playlist(){
    local playlist="$1"
    timestamp "Top Artists for Playlist: $playlist"
    echo >&2
    "$bash_tools/spotify/spotify_playlist_top_artists.sh" "$playlist" |
    # don't waste our time with artists with only 1 track
    sed '/^[[:space:]]*1[[:space:]]/d'
    echo >&2
}

if [ $# -gt 0 ]; then
    for playlist; do
        processs_playlist "$playlist"
    done
else
    while read -r _id playlist; do
        process_playlist "$playlist"
    done < <(
        sed '/^[[:space:]]*$/d' <<< "$playlists"
    )
fi
