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

while read -r line; do
    playlist_id="${line##*https://open.spotify.com/playlist/}"
    playlist_id="${playlist_id%)}"
    playlist_id="${playlist_id%%\?*}"
    if ! is_spotify_playlist_id "$playlist_id"; then
        die "Invalid spotify playlist ID read from README.md: $playlist_id"
    fi
    playlist_name="$(awk -v playlist_id="$playlist_id" '$1 == playlist_id {$1=""; sub(" ", ""); print; exit}' "$srcdir/spotify/playlists.txt")"
    if is_blank "$playlist_name"; then
        die "Failed to parse playlist name from '$srcdir/spotify/playlists.txt' for playlist ID: $playlist_id"
    fi
    playlist_name_escaped="${playlist_name//|/\\|}"
    playlist_name_escaped="${playlist_name_escaped//&/\\&}"
    sed -i "s|\\[.*\\](https://open.spotify.com/playlist/${playlist_id}[[:alnum:]_?\\&=-]*)|[${playlist_name_escaped}](https://open.spotify.com/playlist/$playlist_id)|" README.md
    #awk -v playlist_name="$playlist_name" \
    #    -v playlist_id="$playlist_id" \
    #    '
    #    $0 =~ playlist_id {
    #        gsub("\[.*\\](https://open.spotify.com/playlist/[[:alnum:]?\\&=]*)|[${playlist_name_escaped}](https://open.spotify.com/playlist/$playlist_id))
    #    }
    #'
done < <(
    grep -Eo '\[[^\]+\]\(https://open.spotify.com/playlist/[[:alnum:]_?&=-]+\)' "$srcdir/README.md"
)
