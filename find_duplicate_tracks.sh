#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-20 10:18:09 +0100 (Mon, 20 Jul 2020)
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

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034
usage_description="
Finds duplicate track URIs and track names in the local playlist files
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

cd "$srcdir"

while read -r playlist_name; do
    # converts slashes to unicode so filenames look like the playlists
    filename="$("$srcdir/bash-tools/spotify_playlist_to_filename.sh" "$playlist_name")"
    for x in "$filename" "spotify/$filename"; do
        if ! [ -f "$x" ]; then
            die "File not found: $x"
        fi
    done
    uri_dups="$(sort "spotify/$filename" | uniq -d)"
    if not_blank "$uri_dups"; then
        echo "Duplicates in spotify/$filename:"
        echo
        echo "$uri_dups"
        echo
        echo
    fi
    track_dups="$(sort "$filename" | uniq -d)"
    if not_blank "$track_dups"; then
        echo "Duplicates in $filename:"
        echo
        echo "$track_dups"
        echo
        echo
    fi
done < playlists.txt
