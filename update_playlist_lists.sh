#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2026-01-10 00:08:29 -0500 (Sat, 10 Jan 2026)
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
Updates the playlist names in a given file in the format:

<playlist_id>  <playlist_name>

Used by adjacent scripts:

    update_core_playlist_names.sh
    update_aggregate_playlist_names.sh

referencing the authoritative downloaded playlist ID name mappings in spotify/playlists.txt and private/spotify/playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<files>"

help_usage "$@"

min_args 1 "$@"

playlist_file="$srcdir/spotify/playlists.txt"
private_playlist_file="$srcdir/private/spotify/playlists.txt"

update_playlist_file(){
    local aggregate_playlist_file="$1"
    local tmp
    tmp="$(mktemp)"
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
            close(private_playlist_file)
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

for arg; do
    update_playlist_file "$arg"
done
