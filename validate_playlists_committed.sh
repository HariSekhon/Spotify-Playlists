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

cd "$srcdir"

check(){
    local filename="$1"
    if ! git log -1 "$filename" &>/dev/null; then
        echo "ERROR: playlist file '$filename' is not committed!" >&2
        exit 1
    fi
    if git status --porcelain "$filename" | grep .; then
        echo "ERROR: playlist file '$filename' has outstanding changes!" >&2
        exit 1
    fi
    echo -n .
}

while read -r playlist_file; do
    [ "$playlist_file" = Blacklist ] && continue
    check "$playlist_file"
    check "spotify/$playlist_file"
done < <(
    sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/playlists.txt" |
    "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh"
)

echo
echo "OK - All playlist files committed with no outstanding changes"
