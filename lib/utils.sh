#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-24 18:54:56 +0100 (Fri, 24 Jul 2020)
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
playlist_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# auto-resolve each spotify playlist's path to its file path under ./ or ./private
find_playlist_file(){
    local playlist_name="$1"
    local get_uri_file="${2:-}"  # any value to trigger this logic
    local resolved_file
    is_blank "$playlist_name" && return
    if [ -f "$playlist_dir/${get_uri_file:+spotify/}$playlist_name" ]; then
        resolved_file="$playlist_dir/${get_uri_file:+spotify/}$playlist_name"
    elif [ -f "$playlist_dir/private/${get_uri_file:+spotify/}$playlist_name" ]; then
        resolved_file="$playlist_dir/private/${get_uri_file:+spotify/}$playlist_name"
    else
        die "playlist not found: $playlist_name"
    fi
    log "using file: $resolved_file"
    echo "$resolved_file"
}
export -f find_playlist_file
