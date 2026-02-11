#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-12 02:02:55 -0500 (Mon, 12 Jan 2026)
#
#  https///github.com/HariSekhon/Spotify-playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback
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
Updates the playlist names in README.md and core_playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

no_more_args "$@"

timestamp "Updating README playlist names"
"$srcdir/update_readme_playlist_names.sh"
echo >&2

timestamp "Updating Core playlist names"
"$srcdir/update_playlist_lists.sh" "$srcdir/core_playlists.txt"

timestamp "Updating Core playlist names"
"$srcdir/update_playlist_lists.sh" "$srcdir/best_years_playlists.txt"

timestamp "Updating Aggregations playlist names"
"$srcdir/update_playlist_lists.sh" "$srcdir/../aggregations/"*
