#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-02 19:11:12 +0100 (Thu, 02 Jul 2020)
#
#  https://github.com/harisekhon/playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC2034
usage_description="
One-touch Spotify Backup using code from Spotify Tools and DevOps Bash Tools repos
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="arg [<options>]"

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

help_usage "$@"

cd "$srcdir"

section "Running Spotify Playlists Backup"

timestamp "Dumping list of Spotify playlists to spotify/playlists.txt"
bash-tools/spotify_playlists.sh > spotify/playlists.txt
echo >&2
timestamp "Extracting playlists to playlists.txt"
sed 's/^[^[:space:]]*[[:space:]]*//' spotify/playlists.txt > playlists.txt
echo >&2
