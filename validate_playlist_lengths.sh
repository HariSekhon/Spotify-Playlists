#!/usr/bin/env bash
#  vim:ts=4:sts=4:et
#
#  Author: Hari Sekhon
#  Date: 2013-05-14 20:08:36 +0100 (Tue, 14 May 2013)
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
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$srcdir"

validate_playlist_length(){
    local playlist="${1#./}"
    local spotify_playlist="spotify/$playlist"
    [ -f "$playlist" ] || { echo "File not found: '$playlist'"; exit 1; }
    [ -f "$spotify_playlist" ] || { echo "File not found: '$spotify_playlist'"; exit 1; }
    playlist_wc=$(wc -l "$playlist" | awk '{print $1}')
    spotify_playlist_wc=$(wc -l "$spotify_playlist" | awk '{print $1}')
    if [ "$playlist_wc" != "$spotify_playlist_wc" ]; then
        echo "Playlist $playlist backup invalid, mismatching number of lines ($playlist $playlist_wc vs $spotify_playlist $spotify_playlist_wc)"
        exit 1
    else
        echo "Playlist $playlist ($playlist_wc lines) => $spotify_playlist ($spotify_playlist_wc lines) counts matched"
    fi
}

if [ $# -gt 0 ]; then
    for playlist in "$@"; do
        validate_playlist_length "$playlist"
    done
else
    find . -maxdepth 1 -type f |
    sed 's/^\.\///' |
    grep -vi -e '^\.' -e '\.sh' -e '\.pl' -e '\.txt' -e '\.svn' -e '\.git' -e '\.orig' -e 'TODO' -e 'tocheck' |
    while read -r filename; do
        validate_playlist_length "$filename"
    done
fi
