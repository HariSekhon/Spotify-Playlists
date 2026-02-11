#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-03 18:05:16 +0100 (Fri, 03 Jul 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -x

"$srcdir/validate_playlists_downloaded.sh"
echo
"$srcdir/validate_playlists_committed.sh"
echo
"$srcdir/validate_core_playlists_present.sh"
echo
"$srcdir/validate_playlist_lengths.sh"
