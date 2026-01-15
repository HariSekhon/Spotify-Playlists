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

#if [ -d "$srcdir/../bash-tools" ]; then
#    bash_tools="$srcdir/../bash-tools"
#fi

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Likes all tracks in a given playlist(s) which are not already 'Liked'
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist>"

help_usage "$@"

min_args 1 "$@"

liked='Liked Songs'

for playlist; do
    timestamp "Finding tracks in playlist '$playlist' that are not in '$liked'"
    playlist_file="$(find_playlist_file "$playlist" get_uri_file)"
    grep -Fvxhf "spotify/$playlist_file" "spotify/$liked" |
    tee >(
        echo "Liking the following tracks:"
        echo
        "$bash_tools/spotify/spotify_uri_to_name.sh"
    ) |
    cat
    #"$bash_tools/spotify/spotify_set_tracks_uri_to_liked.sh"
done
