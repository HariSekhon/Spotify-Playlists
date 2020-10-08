#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-25 23:37:23 +0100 (Fri, 25 Sep 2020)
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
. "$srcdir/bash-tools/lib/spotify.sh"

followed_playlists="
Discover Weekly
New Music Friday
Today's Top Hits
Soak Up the Sun
mint
just hits
'90s Baby Makers
Are & Be
You & Me
B.A.E.
The Sweet Suite
Chilled R&B
Soul Lounge
Funk Outta Here
Workout Twerkout
Power Workout
License To Chill
It's ALT Good!
"

# shellcheck disable=SC2034,SC2154
usage_description="
Loads Discover Backlog tracks from the following playlists, then removes duplicates and tracks already in main playlists

Followed Playlists:

$followed_playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

export SPOTIFY_PRIVATE=1

# detect followed playlists so we can convert their playlist names to IDs are well
export SPOTIFY_PLAYLISTS_FOLLOWED=1

spotify_token

while read -r playlist; do
    [ -z "$playlist" ] && continue
    echo
    timestamp "Loading tracks from playlist \"$playlist\" to Discover Backlog"
    "$srcdir/bash-tools/spotify_playlist_tracks_uri.sh" "$playlist" |
    "$srcdir/bash-tools/spotify_add_to_playlist.sh" "Discover Backlog"
done <<< "$followed_playlists"

echo
"$srcdir/bash-tools/spotify_delete_any_duplicates_in_playlist.sh" "Discover Backlog"

echo
"$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog"
