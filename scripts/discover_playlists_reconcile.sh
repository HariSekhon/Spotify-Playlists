#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2022-05-10 16:25:59 +0100 (Tue, 10 May 2022)
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

# Updates the playlist names based on their playlist IDs

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

cd "$srcdir/.."

"$bash_tools/bin/decomment.sh" "$srcdir/private/discover_playlists.txt" |
while read -r line; do
    if ! grep -Fxq "$line" "$srcdir/private/playlists_followed.txt"; then
        if grep -Eq $'\t' <<< "$line"; then
            id="$(awk '{print $1}' <<< "$line")"
            replacement="$(grep -E "^$id"$'\t' "$srcdir/private/playlists_followed.txt" || :)"
            if is_blank "$replacement"; then
                echo "WARNING: failed to find the playlist with ID '$id'" >&2
            else
                sed -i "s|^$id"$'\t'".*|$replacement|" "$srcdir/private/discover_playlists.txt"
            fi
        else
            echo "WARNING: playlist specified without a playlist ID prefix field, brittle, will likely break when externals rename their playlist:  $line" >&2
        fi
    fi
done
