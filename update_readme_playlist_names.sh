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

# shellcheck disable=SC1090,SC1091
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Updates playlist names in README to match the list list downloaded to spotify/playlists.txt
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

no_more_args "$@"

tmp="$(mktemp)"

playlist_file="$srcdir/spotify/playlists.txt"

awk -v playlist_file="$playlist_file" '
    # pre-load playlist file and build hashmap of playlist_id -> playlist_name
    BEGIN {
        while ((getline < playlist_file) > 0) {
            id = $1
            $1 = ""
            sub(/^ /, "")
            name[id] = $0
        }
        close(playlist_file)
    }

    # replace each link with matching playlist_id with whatever the playlist_name is in the map
    # which is the authoritative playlist name dumped from the Spotify API to playlist file
    {
        line = $0

        if (match(line, /\[([^]]*)\]\((https:\/\/open\.spotify\.com\/playlist\/([A-Za-z0-9]+)[^)]*)\)/, m)) {
            id = m[3]
            if (id in name) {
                new_link = "[" name[id] "](" m[2] ")"
                line = substr(line, 1, RSTART-1) new_link substr(line, RSTART+RLENGTH)
            }
        }

        print line
    }
' "$srcdir/README.md" > "$tmp"

mv -f "$tmp" "$srcdir/README.md"
