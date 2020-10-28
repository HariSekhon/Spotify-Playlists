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

discover_playlists="$(sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/discover_playlists.txt")"
num_discover_playlists="$(wc -l <<< "$discover_playlists" | sed 's/[[:space:]]*//g')"

# shellcheck disable=SC2034,SC2154
usage_description="
Loads Discover Backlog tracks from the following playlists, then removes duplicates and tracks already in main playlists

$num_discover_playlists Followed Playlists:

$discover_playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

# check there are no duplicate playlists above slowing us down before we start as this is already a mega load
if sort <<< "$discover_playlists" | uniq -d | grep .; then
    echo "Duplicate playlists detected in code!"
    exit 1
fi

export SPOTIFY_PRIVATE=1

# detect followed playlists so we can convert their playlist names to IDs are well
export SPOTIFY_PLAYLISTS_FOLLOWED=1

spotify_token

time \
while read -r playlist; do
    [ -z "$playlist" ] && continue
    echo
    timestamp "Loading tracks from playlist \"$playlist\" to Discover Backlog"
    "$srcdir/bash-tools/spotify_playlist_tracks_uri.sh" "$playlist" |
    "$srcdir/bash-tools/spotify_add_to_playlist.sh" "Discover Backlog"
done <<< "$discover_playlists"

echo
time {
    time {
        # this often gets an internal 500 error after 1100 track deletions (11 batched calls), seems like a bug in Spotify's API, so run more than once to work around the problem
        for _ in 1 2 3; do
            "$srcdir/bash-tools/spotify_delete_any_duplicates_in_playlist.sh" "Discover Backlog" || continue
            break
        done
    }

    echo
    time {
        "$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog" ||
        "$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog"
    }
}
