#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 02:57:34 +0100 (Sun, 05 Jul 2020)
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

cd "$srcdir"

bash_tools="$srcdir/bash-tools"

# use the newer adjacent checkout if available - useful for development
if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

exec "$bash_tools/scripts/spotify_rename_playlist_files.sh" "$@"
