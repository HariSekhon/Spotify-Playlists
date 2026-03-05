#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-03-05 17:14:51 -0400 (Thu, 05 Mar 2026)
#
#  https///github.com/HariSekhon/Spotify-Playlists
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

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Generates an extensive list of all variations of blacklisted tracks from existing Blacklist* spotify URI lists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

num_args 0 "$@"

cd "$srcdir/.."

spotify_token

while read -r blacklist; do
    blacklisted_uris="private/spotify/$blacklist"
    "$bash_tools/spotify/spotify_search_alternate_track_uris.sh" "$blacklisted_uris"
done < <(
    grep -E '^Blacklist[[:digit:]]*$' "private/playlists.txt" | sort
)
