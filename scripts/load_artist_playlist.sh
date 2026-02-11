#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-11-16 19:22:58 +0000 (Tue, 16 Nov 2021)
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
srcdir="$(dirname "${BASH_SOURCE[0]}")"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Loads all Artist's tracks into a named artist's playlist, from both albums and singles

The artist should have a playlist name matching their artist name

All duplicate and blacklisted tracks are removed afterwards
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<artist>"

help_usage "$@"

min_args 1 "$@"

artist="$1"

export SPOTIFY_PRIVATE=1

spotify_token

"$bash_tools/spotify/spotify_artist_tracks.sh" "$artist" |
"$bash_tools/spotify/spotify_add_to_playlist.sh" "$artist"

echo >&2

"$bash_tools/spotify/spotify_delete_any_duplicates_in_playlist.sh" "$artist"

echo >&2

# want splitting
# shellcheck disable=SC2046
"$bash_tools/spotify/spotify_delete_from_playlist_if_in_other_playlists.sh" "$artist" $(echo "$srcdir/../private/Blacklist"* | sed 's,.*/,,')
