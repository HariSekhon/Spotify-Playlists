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
        # pre-load both public and private playlist files; build id -> name and name -> id
        BEGIN {
            while ((getline < playlist_file) > 0) {
                id = $1
                $1 = ""
                sub(/^[[:space:]]+/, "")
                name[id] = $0
                name_to_id[tolower($0)] = id
            }
            close(playlist_file)

            while ((getline < private_playlist_file) > 0) {
                id = $1
                $1 = ""
                sub(/^[[:space:]]+/, "")
                name[id] = $0
                name_to_id[tolower($0)] = id
            }
            close(private_playlist_file)
        }

        # preserve comments and blank lines verbatim
        /^[[:space:]]*#/ || NF == 0 {
            print
            next
        }

        {
            line = $0
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            id = $1

            # if first field is a known playlist ID -> normalize to id + current name from playlists map
            if (id in name) {
                print id "\t" name[id]
                next
            }

            # if whole line (trimmed) is a playlist name -> replace it with id and name (case insensitive)
            if (tolower(line) in name_to_id) {
                id = name_to_id[tolower(line)]
                print id "\t" name[id]
                next
            }

            printf "ERROR: line is neither a known playlist ID nor a playlist name: %s\n", $0 > "/dev/stderr"
            exit 1
        }
    ' "$aggregate_playlist_file" > "$tmp"

    mv -f "$tmp" "$aggregate_playlist_file"
}

for arg; do
    update_playlist_file "$arg"
done
