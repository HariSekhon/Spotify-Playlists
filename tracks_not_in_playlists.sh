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

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds Tracks not already existing in the major playlist files saved here

Useful to find tracks in playlists such as Liked Songs that aren't saved to the main playlists

Outputs track URIs for further processing (eg. piping to spotify_uri_to_name.sh) or loading straight to playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name>"

help_usage "$@"

min_args 1 "$@"

# allow filtering private playlists
export SPOTIFY_PRIVATE=1

spotify_token

find_missing_tracks(){
    local playlist_name="$1"
    "$srcdir/bash-tools/spotify/spotify_playlist_tracks_uri.sh" "$playlist_name" |
    "$srcdir/filter_tracks_uri_not_in_core_playlists.sh"
}

for playlist_name; do
    find_missing_tracks "$playlist_name"
done
