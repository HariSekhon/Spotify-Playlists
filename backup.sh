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

bash_tools="$srcdir/bash-tools"

# use the newer adjacent checkout if available - useful for development
if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

cd "$srcdir"

# needed to return public playlists that are not explicitly added to profile
export SPOTIFY_PRIVATE=1

export SPOTIFY_PUBLIC_ONLY=1

git pull --no-edit

if [ $# -eq 0 ]; then
    "$srcdir/backup_artists_followed.sh"
fi

exec "$bash_tools/spotify/spotify_backup.sh" "$@"
