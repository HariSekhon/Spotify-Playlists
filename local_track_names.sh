#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-17 06:31:58 -0500 (Sat, 17 Jan 2026)
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
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Lists all local track names so they can be looked up in Spotify to see if I can replace them yet
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

no_more_args "$@"

git grep -h spotify:local: |
sed '
    s/spotify:local:*//;
    s/:[[:digit:]]*$//
    ' |
urldecode.sh |
sed 's/+/ /g' |
sort -fu
