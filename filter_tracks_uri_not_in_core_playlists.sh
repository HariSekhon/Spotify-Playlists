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

# shellcheck disable=SC1090,SC1091
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Filters tracks URIs to only output tracks not already existing in the major playlist files saved here

Useful to find tracks in playlists such as Liked Songs that aren't saved to the main playlists

Accepts track URIs from stdin and prints them to stdout for further processing (eg. piping to spotify_uri_to_name.sh) or loading straight to playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name>"

help_usage "$@"

# allow filtering private playlists
export SPOTIFY_PRIVATE=1

spotify_token

core_playlists="${SPOTIFY_CORE_PLAYLISTS:-$(
    sed 's/^#.*//; /^[[:space:]]*$/d' "$srcdir/core_playlists.txt" |
    awk '{$1=""; print}' |
    "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh"
)}"

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

while read -r uri; do
    eval grep -Fxq "$uri" "$(tr '\n' ' ' <<< "$core_spotify_playlists")" || echo "$uri"
done
