#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 09:35:29 +0100 (Sun, 05 Jul 2020)
#
#  https://github.com/harisekhon/spotify-playlists
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

playlist_count(){
    wc -l playlists.txt | awk '{print $1}'
}

playlist_count="$(playlist_count)"

spotify_playlist_count="$(cd spotify && playlist_count)"

if [ "$playlist_count" != "$spotify_playlist_count" ]; then
    echo "Playlist lists count mismatch between top level playlists.txt and spotify/playlists.txt" >&2
    exit 1
fi

echo
echo "Playlists: $playlist_count"
echo

playlists="$("$srcdir/bash-tools/spotify_playlist_to_filename.sh" < playlists.txt)"

playlists_linecount(){
    while read -r playlist; do
        printf '%s\0' "$playlist"
    done <<< "$playlists" |
    xargs -0 wc -l |
    awk '/^[[:space:]]*[[:digit:]]*[[:space:]]*total[[:space:]]*$/{print $1}'
}

song_count="$(playlists_linecount)"

spotify_song_count="$(cd spotify && playlists_linecount)"

if [ "$song_count" != "$spotify_song_count" ]; then
    echo "Song count mismatch between top level and spotify/" >&2
    exit 1
fi

echo "Song Count: $song_count"
echo

playlists_linecount_uniq(){
    while read -r playlist; do
        cat "$playlist"
    done <<< "$playlists" |
    spotify-tools/normalize_tracknames.pl |
    sort -u |
    wc -l |
    sed 's/[[:space:]]//g'
}

printf "Unique Song Count: "
playlists_linecount_uniq

echo
