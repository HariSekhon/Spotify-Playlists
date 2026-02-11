#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-15 16:58:29 -0500 (Thu, 15 Jan 2026)
#
#  https///github.com/HariSekhon/Spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/bash-tools"

if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Likes all tracks in a given playlist(s) which are not already 'Liked'
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="[<playlist> <playlist2> ...]"

help_usage "$@"

#min_args 1 "$@"

liked='Liked Songs'

spotify_token

track_uris="$(
    while read -r playlist; do
        timestamp "Finding tracks in playlist '$playlist' that are not in '$liked'"
        playlist_file="$(find_playlist_file "$playlist" get_uri_file)"
        # exclude local tracks since they can't be Liked in Spotify
        grep -Fvxhf "spotify/$liked" "$playlist_file" | sed '/^spotify:local:/d' || :
    done  < <(
        if [ $# -gt 0 ]; then
            for arg; do
                echo "$arg"
            done
        else
            sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/like_playlists.txt" |
            awk '{ $1=""; print }'
        fi
    ) |
    sort -u
)"

# here string <<< unconditionally adds a \n which creates an off-by-one error returning 1 even for an empty variable
#count="$(wc -l <<< "$track_uris" | sed 's/[[:space:]]//g')"
count="$(grep -c . <<< "$track_uris" || :)"

# this also works
#count="$(printf '%s' "$track_uris" | wc -l)"

# not really needed since grep -c will always return an int
is_int "$count" || die "Non-integer track count returned"

if [ "$count" = 0 ]; then
    timestamp "No tracks unLiked tracks found"
    exit 0
fi

echo
echo "Tracks in playlist(s) that are not currently 'Liked':"
echo

"$bash_tools/spotify/spotify_uri_to_name.sh" <<< "$track_uris"

echo

read -r -p "Are you happy to Like these $count tracks? (y/N) " answer

if ! [[ "$answer" =~ ^(y|yes) ]]; then
    die "Aborting..."
fi

"$bash_tools/spotify/spotify_set_tracks_uri_to_liked.sh" <<< "$track_uris"

echo >&2
timestamp "Completed Liking $count Songs"
echo >&2
timestamp "Remember track comparisons are done using downloaded playlist URIs for spped - you must run this before retrying:"
echo >&2
echo "./backup.sh liked" >&2
echo >&2
