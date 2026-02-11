#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 09:35:29 +0100 (Sun, 05 Jul 2020)
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

if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

cd "$srcdir"

playlist_count(){
    wc -l playlists.txt | awk '{print $1}'
}

playlist_count="$(playlist_count)"

spotify_playlist_count="$(cd spotify && playlist_count)"

if [ "$playlist_count" != "$spotify_playlist_count" ]; then
    echo "Playlist lists count mismatch between top level playlists.txt ($playlist_count) vs spotify/playlists.txt ($spotify_playlist_count)" >&2
    echo >&2
    tmp="$(mktemp)"
    # normalize the spotify playlists by stripping the IDs field (22 alnum chars and whitespace) so we can directly diff the playlists vs spotify playlists
    cut -c 24- spotify/playlists.txt > "$tmp"
    diff playlists.txt "$tmp" >&2
    exit 1
fi

echo
echo "Playlists: $playlist_count"
echo

playlists="$("$bash_tools/spotify/spotify_playlist_to_filename.sh" < playlists.txt)"

playlists_linecounts(){
    while read -r playlist; do
        if ! [ -f "$playlist" ]; then
            playlist="$(find . -maxdepth 2 -name "$playlist" | sed '/spotify/d' | head -n1 || :)"
        fi
        printf '%s\0' "$playlist"
    done <<< "$playlists" |
    xargs -0 wc -l --
}
export -f playlists_linecounts

playlists_linecount(){
    playlists_linecounts |
    awk '/^[[:space:]]*[[:digit:]]*[[:space:]]*total[[:space:]]*$/{print $1}'
}
export -f playlists_linecount

song_count="$(playlists_linecount)"

spotify_song_count="$(cd spotify && playlists_linecount)"

if [ "$song_count" != "$spotify_song_count" ]; then
    echo "WARNING: Song count mismatch between top level ($song_count) vs spotify/ ($spotify_song_count)" >&2
    echo >&2
    diff <(playlists_linecounts) <(cd spotify && playlists_linecounts) >&2 || :
    #exit 1
fi

echo "Song Count: $song_count"
echo

playlists_linecount_uniq(){
    while read -r playlist; do
        [[ "$playlist" =~ Love\ I\  ]] && continue
        if [ -f "$playlist" ]; then
            :
        elif [ -f "Mixes in Time/$playlist" ]; then
            # neither this nor the find below is matching the Leaving It All Behind playlist, must be emoji weirdness
            playlist="Mixes in Time/$playlist"
        elif [ -f "Artists/$playlist" ]; then
            playlist="Artists/$playlist"
        else
            playlist="$(
                find . -maxdepth 2 -name "$playlist" |
                sed '/spotify/d' |
                head -n1 || :
            )"
        fi
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
