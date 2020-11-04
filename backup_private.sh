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

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090
. "$bash_tools/lib/spotify.sh"

cd "$srcdir"

export SPOTIFY_PRIVATE=1
export SPOTIFY_PRIVATE_ONLY=1

export SPOTIFY_BACKUP_DIR="private"

# This is done in Makefile before both backup playlists are called
#
# auth pop-up once up front if no SPOTIFY_ACCESS_TOKEN found instead of multiple times (once for each called script)
spotify_token
# force re-auth since token only lasts for 1 hour and this can take 10 minutes, we don't want the token to expire and error out the scripts part way through
#SPOTIFY_ACCESS_TOKEN="$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify_api_token.sh)"
#export SPOTIFY_ACCESS_TOKEN

timestamp "Backing up list of Spotify private playlists to $srcdir/private/spotify/playlists.txt"
SPOTIFY_PLAYLISTS_FOLLOWED=1 "$bash_tools/spotify_playlists.sh" > "$srcdir/private/spotify/playlists.txt"
echo >&2

timestamp "Stripping spotify playlist IDs from $srcdir/private/spotify/playlists.txt => $srcdir/private/playlists.txt"
sed 's/^[^[:space:]]*[[:space:]]*//' "$srcdir/private/spotify/playlists.txt" > "$srcdir/private/playlists.txt"
echo >&2

timestamp "Backing up Artists followed"
"$bash_tools/spotify_artists_followed.sh" | sort -f > artists_followed.txt
echo >&2

timestamp "Backing up Artists followed URIs"
"$bash_tools/spotify_artists_followed_uri.sh" | sort -f > spotify/artists_followed.txt
echo >&2

timestamp "Regenerating Blacklisted Artists"
"$srcdir/blacklisted_artists.sh" >/dev/null
echo >&2

"$srcdir/bash-tools/spotify_backup.sh" "$@"

if [ $# -eq 0 ]; then
    echo

    "$srcdir/bash-tools/spotify_backup_playlist.sh" liked

    echo
fi

for subdir in . spotify; do
    if [ -f "private/$subdir/Liked Songs" ]; then
        #mv -fv "private/$subdir/Liked Songs" "$subdir/Liked Songs"
        sort -f "private/$subdir/Liked Songs" > "$subdir/Liked Songs"
    fi
done
