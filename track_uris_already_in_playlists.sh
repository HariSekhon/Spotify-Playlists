#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-18 11:19:20 -0500 (Sun, 18 Jan 2026)
#
#  https///github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn
#  and optionally send me feedback
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$srcdir/../bash-tools" ]; then
    bash_tools="$srcdir/../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/utils.sh"

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/playlist-utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Finds track URIs in given spotify playlist that are in the other given spotify/ URI export files
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist> <in_this_playlist> [<in_this_playlist> ...]"

help_usage "$@"

min_args 2 "$@"

playlist_name="$1"
shift || :

# requires GNU grep to work, Mac's grep is buggy with use of -f
if is_mac; then
    grep(){
        command ggrep "$@"
    }
fi

playlist_file="$(find_playlist_file "$playlist_name" get_uri_file)"

other_playlists=()
for arg; do
    other_playlists+=("$arg")
done

other_playlist_files=()
for other_playlist in "${other_playlists[@]}"; do
    other_playlist_files+=("$(find_playlist_file "$other_playlist" get_uri_file)")
done

filter_URIs(){
    local playlist_file="$1"
    local other_playlist_file="$2"
    #validate_spotify_uri "$(head -n 1 "$spotify_filename")" >/dev/null
    timestamp "Finding tracks in '$playlist_file' by exact URI matches in other playlist file: $other_playlist_file"
    grep -Fxh -f "$other_playlist_file" "$playlist_file" || :
}

for other_playlist_file in "${other_playlist_files[@]}"; do
    filter_URIs "$playlist_file" "$other_playlist_file"
done
