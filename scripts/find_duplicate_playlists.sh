#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-11-06 23:16:18 +0000 (Fri, 06 Nov 2020)
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
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds duplicate playlists in playlists.txt and private/playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

cd "$srcdir"

exitcode=0

for playlists_file in "$srcdir/../playlists.txt" "$srcdir/../private/playlists.txt"; do
    if [ -f "$playlists_file" ]; then
        duplicate_playlists="$(sort "$playlists_file" | uniq -d)"
        if [ -n "$duplicate_playlists" ]; then
            echo "Duplicate playlists in $playlists_file:"
            echo
            echo "$duplicate_playlists"
            echo
            exitcode=1
        fi
    fi
done

exit $exitcode
