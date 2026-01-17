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

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes duplicates between blacklist playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

die "DON'T RUN THIS - might be useful to have alternate URI versions in other blacklists for quicker removals"

export SPOTIFY_PRIVATE=1

spotify_token

blacklists=()

while read -r blacklist; do
    blacklists+=("$blacklist")
done < <(
    grep -E '^Blacklist[[:digit:]]*$' "$srcdir/private/playlists.txt" | sort
)

"$srcdir/bash-tools/spotify/spotify_delete_from_playlist_if_in_other_playlists.sh" "${blacklists[@]}"
