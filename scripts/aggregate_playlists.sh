#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-11-06 17:32:54 +0000 (Fri, 06 Nov 2020)
#
#  https://github.com/HariSekhon/Spotify-Playlists
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash_tools="$srcdir/../bash-tools"

if [ -d "$srcdir/../../bash-tools" ]; then
    bash_tools="$srcdir/../../bash-tools"
fi

# shellcheck disable=SC1090,SC1091
. "$bash_tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Ensure tracks in more specialized playlists are also in their super mega mix playlist parents

The mappings are in the local aggregations/ directory, each file being named after the mega mix playlist and each line of contents being the playlist from while to filter to

Takes a full backup before starting to avoid loading duplicates due to out of date local playlists
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

cd "$srcdir/.."

if is_mac; then
    if ! type -P ggrep &>/dev/null; then
        die "GNU grep 'ggrep' not installed"
    fi
    grep(){
        command ggrep "$@"
    }
fi

export SPOTIFY_PRIVATE=1
spotify_token

# XXX: important to have up to date playlists otherwise will load duplicates
# backup is now a dependency of aggregate in Makefile
#./backup.sh

for mega_playlist_file in aggregations/*; do
    mega_playlist="${mega_playlist_file#aggregations/}"
    mega_playlist_spotify_file="spotify/$mega_playlist_file"
    hr
    timestamp "Backporting to mega playlist '$mega_playlist'"
    hr
    echo >&2
    for filename in "$mega_playlist_file" "$mega_playlist_spotify_file"; do
        if ! [ -f "$mega_playlist_file" ]; then
            die "ERROR: mega playlist file not found '$filename'"
        fi
    done
    # shellcheck disable=SC2094
    while read -r playlist; do
        playlist_file="spotify/$("$bash_tools/spotify/spotify_playlist_to_filename.sh" "$playlist")"
        if ! [ -f "$playlist_file" ]; then
            die "ERROR: playlist file not found '$playlist_file'"
        fi
        [ -z "${DEBUG_TRANSLATE:-}" ] || hr2
        timestamp "Backporting playlist '$playlist' to mega playlist '$mega_playlist'"
        [ -z "${DEBUG_TRANSLATE:-}" ] || hr2
        # slow, waste of forks
        #while read -r uri; do
        #    grep -Fxq "$uri" "spotify/$mega_playlist" ||
        #    echo "$uri"
        #done < "$playlist_file"
        #
        # grep bubbles up a hard to debug exit 1 code if no matches
        { grep -Fxv -f "spotify/$mega_playlist" "$playlist_file" || : ; } |
        if [ -n "${DEBUG_TRANSLATE:-}" ]; then
            "$bash_tools/spotify/spotify_uri_to_name.sh"
        else
            cat
        fi
        echo >&2
    done < <(sed 's/#.*//; /^[[:digit:]]*$/d' "$mega_playlist_file") |
    if [ -n "${DEBUG_TRANSLATE:-}" ]; then
        cat
    else
        sort -u |
        # will call spotify_playlist_to_filename.sh to do the right thing, pre-converting it will actually blow up by stripping the leading slash
        "$bash_tools/spotify/spotify_add_to_playlist.sh" "$mega_playlist"
    fi
    echo >&2
done

# re-dump the aggregated playlists as soon as we're done. Could have just tee'd the URIs into the playlist files tbh but this feels more accurate using the API albeit slower
if [ -z "${DEBUG_TRANSLATE:-}" ]; then
    mega_playlists=()
    for mega_playlist_file in aggregations/*; do
        playlist="${mega_playlist_file#aggregations/}"
        mega_playlists+=("$playlist")
    done
    "$bash_tools/spotify/spotify_delete_duplicates_in_playlist.sh" "${mega_playlists[@]}"
    ./backup.sh "${mega_playlists[@]}"
fi
