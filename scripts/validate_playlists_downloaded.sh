#!/usr/bin/env bash
#  vim:ts=4:sts=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-26 23:57:05 +0100 (Sat, 26 Sep 2020)
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
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

cd "$srcdir/.."

echo "Checking all playlists in playlists.txt are downloaded:"
while read -r playlist_file; do
    [ "$playlist_file" = Blacklist ] && continue
    if ! [ -f "$playlist_file" ]; then
        echo "playlist file '$playlist_file' not found!"
        exit 1
    fi
    if ! [ -f "spotify/$playlist_file" ]; then
        echo "playlist spotify file '$playlist_file' not found!"
        exit 1
    fi
    echo -n '.'
done < <(
    sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/../playlists.txt" |
    "$bash_tools/spotify/spotify_playlist_to_filename.sh"
)

echo
echo "OK - All playlist files downloaded"
