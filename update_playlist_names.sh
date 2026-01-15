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

# shellcheck disable=SC1090,SC1091
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Updates the playlist names in README.md and core_playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

no_more_args "$@"

timestamp "Calling update_readme_playlist_names.sh"
"$srcdir/update_readme_playlist_names.sh"
echo >&2

timestamp "Calling update_core_playlist_names.sh"
"$srcdir/update_core_playlist_names.sh"

timestamp "Calling update_aggregate_playlist_names.sh"
"$srcdir/update_aggregate_playlist_names.sh"
