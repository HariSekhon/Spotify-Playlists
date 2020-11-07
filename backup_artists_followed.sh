#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-11-07 00:30:25 +0000 (Sat, 07 Nov 2020)
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

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090
. "$bash_tools/lib/spotify.sh"

cd "$srcdir"

make pull

export SPOTIFY_PRIVATE=1

spotify_token

timestamp "Backing up Artists followed"
"$bash_tools/spotify_artists_followed.sh" | sort -f > artists_followed.txt
echo >&2

timestamp "Backing up Artists followed URIs"
"$bash_tools/spotify_artists_followed_uri.sh" | sort -f > spotify/artists_followed.txt
echo >&2
