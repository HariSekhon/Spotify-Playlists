#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  args: "Upbeat & Sexual Pop"
#
#  Author: Hari Sekhon
#  Date: 2020-07-20 10:18:09 +0100 (Mon, 20 Jul 2020)
#  Original Date: 2012-04-15 19:31:27 +0100 (Sun, 15 Apr 2012)
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

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034
usage_description="
Finds duplicate track URIs and track names in the local playlist files

Playlists can be explicitly specified as arg giving their local file basename, otherwise
iterates all playlists as found in playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="playlist1 playlist2 ..."

help_usage "$@"

cd "$srcdir"

find_duplicate_tracks(){
    local playlist_name="$1"
    # converts slashes to unicode so filenames look like the playlists
    filename="$("$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh" "$playlist_name")"
    for x in "$filename" "spotify/$filename"; do
        if ! [ -f "$x" ]; then
            die "File not found: $x"
        fi
    done
    uri_dups="$(sort "spotify/$filename" | uniq -d -i)"
    if not_blank "$uri_dups"; then
        echo
        echo "* Duplicates in spotify/$filename:"
        echo
        echo "$uri_dups"
        echo
    fi
    track_dups="$(sort "$filename" | uniq -d -i)"
    if not_blank "$track_dups"; then
        echo
        echo "* Duplicates in $filename:"
        echo
        echo "$track_dups"
        echo
    fi
}

if [ $# -gt 0 ]; then
    for playlist_name in "$@"; do
        find_duplicate_tracks "$playlist_name"
    done
else
    while read -r playlist_name; do
        find_duplicate_tracks "$playlist_name"
    done < playlists.txt
fi
