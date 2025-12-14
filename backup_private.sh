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
. "$bash_tools/lib/spotify.sh"

cd "$srcdir"

export SPOTIFY_PRIVATE=1
export SPOTIFY_PRIVATE_ONLY=1

# include followed playlists both for getting a full playlist.txt and also for using for discover_blacklisted.sh percentages
export SPOTIFY_PLAYLISTS_FOLLOWED=1

export SPOTIFY_BACKUP_DIR="private"

# This is done in Makefile before both backup playlists are called
#
# auth pop-up once up front if no SPOTIFY_ACCESS_TOKEN found instead of multiple times (once for each called script)
spotify_token
# force re-auth since token only lasts for 1 hour and this can take 10 minutes, we don't want the token to expire and error out the scripts part way through
#SPOTIFY_ACCESS_TOKEN="$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify/spotify_api_token.sh)"
#export SPOTIFY_ACCESS_TOKEN

git pull --no-edit

if [ -n "$*" ]; then
    "$bash_tools/spotify/spotify_backup.sh" "$@"
    exit 0
fi

timestamp "Backing up list of Spotify private playlists to $srcdir/private/spotify/playlists.txt"
SPOTIFY_PLAYLISTS_FOLLOWED=1 "$bash_tools/spotify/spotify_playlists.sh" > "$srcdir/private/spotify/playlists.txt"
echo >&2

timestamp "Stripping spotify playlist IDs from $srcdir/private/spotify/playlists.txt => $srcdir/private/playlists.txt"
sed 's/^[^[:space:]]*[[:space:]]*//' "$srcdir/private/spotify/playlists.txt" > "$srcdir/private/playlists.txt"
echo >&2

"$srcdir/backup_artists_followed.sh"

timestamp "Regenerating Blacklisted Artists"
"$srcdir/blacklisted_artists.sh" >/dev/null
echo >&2

"$bash_tools/spotify/spotify_backup.sh" "$@"

if [ $# -eq 0 ]; then
    echo

    "$bash_tools/spotify/spotify_backup_playlist.sh" liked

    echo
fi

for subdir in . spotify; do
    if [ -f "private/$subdir/Liked Songs" ]; then
        #mv -fv "private/$subdir/Liked Songs" "$subdir/Liked Songs"
        sort -f "private/$subdir/Liked Songs" > "$subdir/Liked Songs"
    fi
done
