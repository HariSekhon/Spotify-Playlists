#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-26 19:58:55 +0100 (Sun, 26 Jul 2020)
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

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes tracks from a given playlist that are already in Blacklist playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_name> [<playlist_name2> ...]"

help_usage "$@"

min_args 1 "$@"

export SPOTIFY_PRIVATE=1

# pre-load token once for deletions and URI=>track name resolving prompt to avoid repeated pop-ups
spotify_token

# assume we are reasonably up to date since these tracks have a large stock to flow ratio and
# we can always run a partial backup of just the latest Blacklist playlist manually if we want a fresher list
#"$srcdir/backup_private.sh" $("$srcdir/bash-tools/spotify_playlists.sh" | grep -E '^Blacklist[[:digit:]]+$')

blacklists=()

while read -r blacklist; do
    blacklists+=("$blacklist")
done < <(
    grep -E '^Blacklist[[:digit:]]*$' "$srcdir/private/playlists.txt" | sort
)

for playlist; do
    if [[ "$playlist" =~ Blacklist ]]; then
        warn "Cannot specify to delete from a Blacklist itself"
        continue
    fi
    "$srcdir/delete_tracks_already_in_playlists.sh" "$playlist" "${blacklists[@]}"
done
