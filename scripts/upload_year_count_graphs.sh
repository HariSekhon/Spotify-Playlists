#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-02-11 04:11:39 -0300 (Wed, 11 Feb 2026)
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
. "$bash_tools/lib/utils.sh"


# shellcheck disable=SC2034,SC2154
usage_description="
Uploads the tracks per year graph to a GitHub release to serve out without permanently polluting history
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="arg [<options>]"

help_usage "$@"

no_args "$@"

repo="HariSekhon/Spotify-Playlists"
tag="graphs"
file="$srcdir/tracks_per_year.png"

gh release create "$tag" \
                  --repo "$repo" \
                  --title "$tag" \
                  --notes "" \
                  --latest \
                  --prerelease 2>/dev/null || :

gh release upload "$tag" "$file" --clobber --repo "$repo"

# Downloads the graph
#"$bash_tools/bin/urlopen.sh" "https://github.com/$repo/releases/download/graphs/${file##*/}"
echo "URL: https://github.com/$repo/releases/download/graphs/${file##*/}"
