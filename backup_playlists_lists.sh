#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-11-07 00:10:56 +0000 (Sat, 07 Nov 2020)
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

# shellcheck disable=SC1090
. "$bash_tools/lib/spotify.sh"

cd "$srcdir"

make pull

export SPOTIFY_PRIVATE=1

# This is done in Makefile before both backup playlists are called
#
# auth pop-up once up front if no SPOTIFY_ACCESS_TOKEN found instead of multiple times (once for each called script)
spotify_token
# force re-auth since token only lasts for 1 hour and this can take 10 minutes, we don't want the token to expire and error out the scripts part way through
#SPOTIFY_ACCESS_TOKEN="$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify/spotify_api_token.sh)"
#export SPOTIFY_ACCESS_TOKEN

export SPOTIFY_PUBLIC_ONLY=1

timestamp "Backing up list of Spotify public playlists to $srcdir/spotify/playlists.txt"
"$bash_tools/spotify/spotify_playlists.sh" > "$srcdir/spotify/playlists.txt"
echo >&2

timestamp "Stripping spotify playlist IDs from $srcdir/spotify/playlists.txt => $srcdir/playlists.txt"
sed 's/^[^[:space:]]*[[:space:]]*//' "$srcdir/spotify/playlists.txt" > "$srcdir/playlists.txt"
echo >&2

timestamp "Backing up list of Spotify followed playlists to $srcdir/private/playlists_followed.txt"
SPOTIFY_PUBLIC_ONLY='' \
SPOTIFY_PLAYLISTS_FOLLOWED_ONLY=1 \
"$bash_tools/spotify/spotify_playlists.sh" | sort -f > "$srcdir/private/playlists_followed.txt"
echo >&2

if [ -d private ]; then
    unset SPOTIFY_PUBLIC_ONLY
    export SPOTIFY_PRIVATE_ONLY=1

    timestamp "Backing up list of Spotify private playlists to $srcdir/private/spotify/playlists.txt"
    "$bash_tools/spotify/spotify_playlists.sh" > "$srcdir/private/spotify/playlists.txt"
    echo >&2

    timestamp "Stripping spotify playlist IDs from $srcdir/private/spotify/playlists.txt => $srcdir/private/playlists.txt"
    sed 's/^[^[:space:]]*[[:space:]]*//' "$srcdir/private/spotify/playlists.txt" > "$srcdir/private/playlists.txt"
    echo >&2
fi

timestamp "Running discover_playlists_reconcile.sh"
"$srcdir/discover_playlists_reconcile.sh"
echo >&2
