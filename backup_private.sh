#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 02:57:34 +0100 (Sun, 05 Jul 2020)
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

cd "$srcdir"

export SPOTIFY_PRIVATE=1
export SPOTIFY_PRIVATE_ONLY=1

export SPOTIFY_BACKUP_DIR="private"

"$srcdir/bash-tools/spotify_backup.sh" "$@"

echo

"$srcdir/bash-tools/spotify_backup_playlist.sh" liked

echo

command mv -fv {private/,}"Liked Songs"
command mv -fv {private/spotify/,spotify/}"Liked Songs"
