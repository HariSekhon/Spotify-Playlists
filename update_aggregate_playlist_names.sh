#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-15 18:24:07 -0500 (Thu, 15 Jan 2026)
#
#  https///github.com/HariSekhon/Spotify-playlists
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

# shellcheck disable=SC1090,SC1091
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Updates the aggregate playlist names that are used by:

    aggregate_playlists.sh

from the spotify/playlists.txt or private/playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

no_more_args "$@"

playlist_file="$srcdir/spotify/playlists.txt"
private_playlist_file="$srcdir/private/spotify/playlists.txt"

tmp="$(mktemp)"

tmp="$(mktemp)"

process_aggregate_playlist_file(){
    local aggregate_playlist_file="$1"
    awk -v playlist_file="$playlist_file" -v private_playlist_file="$private_playlist_file" '
        # pre-load both public and private playlist files and build hashmap of playlist_id -> playlist_name
        BEGIN {
            while ((getline < playlist_file) > 0) {
                id = $1
                $1 = ""
                sub(/^ /, "")
                name[id] = $0
            }
            close(playlist_file)

            while ((getline < private_playlist_file) > 0) {
                id = $1
                $1 = ""
                sub(/^ /, "")
                name[id] = $0
            }
            close(playlist_file)
        }

        # preserve comments and blank lines verbatim
        /^[[:space:]]*#/ || NF == 0 {
            print
            next
        }

        {
            id = $1

            if (!(id in name)) {
                printf "ERROR: playlist ID not found in playlists file: %s\n", id > "/dev/stderr"
                exit 1
            }

            # Replace everything after the ID with the current name
            # (dumped from the Spotify API to the playlist files)
            print id "\t" name[id]
        }
    ' "$aggregate_playlist_file" > "$tmp"

    mv -f "$tmp" "$aggregate_playlist_file"
}

for playlist_file in aggregations/*; do
    process_aggregate_playlist_file "$playlist_file"
done
