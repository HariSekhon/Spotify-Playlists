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

# shellcheck disable=SC2034,SC2154
usage_description="
Duduplicates Discover Backlog tracks against itself and then removes tracks already in main playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

export SPOTIFY_PRIVATE=1

spotify_token

export SPOTIFY_DELETE_IGNORE_IRREGULAR_IDS=1

# 18m
time {

# 8m
time {
    # this often gets a "500 Internal Server Error" after 1100 track deletions (11 batched calls), seems like a bug in Spotify's API, so run more than once to work around the problem
    # also, will hit "400 Could not remove tracks, please check parameters." if you delete any tracks from Discover Backlog while this is running it'll throw the track positions off
    for _ in {1..6}; do
        "$srcdir/bash-tools/spotify_delete_any_duplicates_in_playlist.sh" "Discover Backlog" || continue
        break
    done
}

echo
# 9m
time {
    # Spotify's API gets random errors, so need to retry a couple times, more for huge discover backlog loaded (now 100+ playlists loaded > 10,000 tracks)
    for _ in {1..6}; do
        "$srcdir/delete_tracks_already_in_playlists.sh" "Discover Backlog" || continue
        break
    done
}

}
