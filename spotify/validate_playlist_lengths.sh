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
    local playlist="$1"
    local tracklist="../$playlist"
    [ -f "$playlist" ] || { echo "File not found: '$playlist'"; exit 1; }
    [ -f "$tracklist" ] || { echo "File not found: '$tracklist'"; exit 1; }
    playlist_wc=$(wc -l "$playlist" | awk '{print $1}')
    tracklist_wc=$(wc -l "$tracklist" | awk '{print $1}')
    if [ "$playlist_wc" != "$tracklist_wc" ]; then
        echo "Playlist $playlist dump invalid, mismatching number of lines ($playlist $playlist_wc vs $tracklist $tracklist_wc)"
        exit 1
    else
        echo "Playlist $playlist $playlist_wc => $tracklist $tracklist_wc line counts matched"
    fi
}

if [ $# -gt 0 ]; then
    for playlist in "$@"; do
        validate_playlist_length "$playlist"
    done
else
    find . -type f | grep -vi -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck" |
    while read -r filename; do
        validate_playlist_length "$filename"
    done
fi
