#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 11:00:55 +0100 (Sun, 05 Jul 2020)
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

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC2034
usage_description="
Convert every playlist under spotify/ to human readable format at top level
using bash-tools/spotify/spotify_uri_to_name.sh

Git diff should show no differences between this result and the
spotify_playlist_backup.sh playlists human output at the top level

This is intended to run once in a while as an extra verification
as it takes a long time do query the Spotify API for all these tracks
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<curl_options>]"

help_usage "$@"

cd "$srcdir/.."

playlists="$(bash-tools/spotify/spotify_playlist_to_filename.sh < playlists.txt)"

convert(){
    local playlist="$1"
    shift
    timestamp "converting  'spotify/$playlist'  =>  '$playlist'"
    "$bash_tools/spotify/spotify_uri_to_name.sh" "$@" < "spotify/$playlist" > "$playlist"
}

if [ $# -gt 0 ]; then
    for playlist in "$@"; do
        if [ -f "$playlist" ] && [ -f "spotify/$playlist" ]; then
            shift
            convert "$playlist" "$@"
        else
            break
        fi
    done
else
    while read -r playlist; do
        convert "$playlist"
    done <<< "$playlists"
fi
timestamp "Done"
