#!/usr/bin/env bash
#  vim:ts=4:sts=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-26 09:54:02 +0100 (Sat, 26 Sep 2020)
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

cd "$srcdir"

echo "Checking Core Playlist files are present:"
while read -r playlist_file; do
    if [[ "$playlist_file" =~ Blacklist ]]; then
        if ! [ -f "private/$playlist_file" ]; then
            echo "core playlist file 'private/$playlist_file' not found!"
            exit 1
        fi
    elif ! [ -f "$playlist_file" ]; then
        echo "core playlist file '$playlist_file' not found!"
        exit 1
    fi
    echo -n .
done < <(
    sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/core_playlists.txt" |
    awk '{$1=""; print}' |
    "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh"
)
echo
echo "OK - All core playlist files found"
