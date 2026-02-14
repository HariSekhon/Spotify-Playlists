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
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

spotify_tools="$srcdir/../spotify-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

if [ -d "$srcdir/../../spotify-tools" ]; then
    spotify_tools="$srcdir/../../spotify-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/playlist-utils.sh"

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

cd "$srcdir/.."

find_duplicate_tracks(){
    local playlist_name="$1"
    # converts slashes to unicode so filenames look like the playlists
    filename="$("$bash_tools/spotify/spotify_playlist_to_filename.sh" "$playlist_name")"
    filename="$(find_playlist_file "$filename")"
    spotify_filename="$(find_playlist_file "$filename" get_uri_path)"
    uri_dups="$(
        sort "$spotify_filename" |
        uniq -d -i
    )"
    if not_blank "$uri_dups"; then
        echo
        echo "* Duplicates in $spotify_filename:"
        echo
        echo "$uri_dups"
        echo
    fi
    track_dups="$(
        "$spotify_tools/normalize_tracknames.pl" < "$filename" |
        sort |
        uniq -d -i
    )"
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
    while read -r _playlist_id playlist_name; do
        find_duplicate_tracks "$playlist_name"
    done < "$srcdir/../playlists.txt"
fi
