#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2021-11-25 19:01:41 +0000 (Thu, 25 Nov 2021)
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
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes duplicate URIs in later Blacklist playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

export SPOTIFY_PRIVATE=1

spotify_token

blacklists=()

while read -r blacklist; do
    blacklists+=("$blacklist")
done < <(
    # reverse sort so we remove the duplicates from the highest number Blacklist and leave the original one untouched
    grep -E '^Blacklist[[:digit:]]*$' "$srcdir/../private/playlists.txt" | sort -nr
)

# loop should end when we are down to last blacklist which should be the original Blacklist
while [ "${#blacklists[@]}" -gt 1 ]; do

    target_blacklist="${blacklists[0]}"

    timestamp "Removing exact duplicate URIs from: $target_blacklist"

    # Extremely inefficient as it's pulling the entire tracklist live while we have downloaded URI playlist copies
    #"$srcdir/bash-tools/spotify/spotify_delete_from_playlist_if_in_other_playlists.sh" "${blacklists[@]}"

    # Fast as it is just grepping local files
    "$srcdir/../track_uris_already_in_playlists.sh" "${blacklists[@]}" |
    sort -u |
    "$bash_tools/spotify/spotify_delete_from_playlist.sh" "$target_blacklist"

    # pop off first item from array - must be done at end of loop because we want the first item to be the first arg to delete from
    blacklists=( "${blacklists[@]:1}" )
done
