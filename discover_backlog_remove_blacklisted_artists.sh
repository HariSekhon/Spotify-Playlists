#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-10-31 10:23:36 +0000 (Sat, 31 Oct 2020)
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

# shellcheck disable=SC1090
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes tracks from the most blacklisted artists (as determined by the adjacent blacklisted_artists.sh script) by with N+ blacklisted tracks and no entries in the core playlists

Useful get rid of overrated artists from recommendations loaded in to Discover Backlog buffer playlist
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"

export SPOTIFY_PRIVATE=1

spotify_token

bash_tools="$srcdir/bash-tools"

# TODO: dedupe this with tracks_already_in_playlists.sh, move to lib/spotify.sh or rework the logic to be simpler
core_playlists=()
while read -r playlist; do
    if [[ "$playlist" =~ Blacklist|Discover|TODO|Backlog ]]; then
        continue
    fi
    # auto-resolve each playlist's path to either ./ or ./private
    if [ -f "$srcdir/$playlist" ]; then
        core_playlists+=("$srcdir/$playlist")
    elif [ -f "$srcdir/private/$playlist" ]; then
        core_playlists+=("$srcdir/private/$playlist")
    else
        die "playlist not found: $playlist"
    fi
done < <(
    sed 's/^#.*//; /^[[:space:]]*$/d' "$srcdir/core_playlists.txt" |
    "$srcdir/bash-tools/spotify/spotify_playlist_to_filename.sh"
)

#timestamp "Getting list of blacklisted artists with >= N tracks in Blacklist but not in core playlists"
#blacklisted_artists="$("$bash_tools/blacklisted_artists.sh")"
blacklisted_artists="$(sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//; /^[[:space:]]*$/d' "$srcdir/private/blacklisted_artists.txt")"

timestamp "Finding tracks in Discover Backlog by blacklisted artists"

playlist_id="$("$bash_tools/spotify/spotify_playlist_name_to_id.sh" "Discover Backlog")"

# defined in lib/spotify.sh
# shellcheck disable=SC2154
url_path="/v1/playlists/$playlist_id/tracks?limit=100&offset=$offset"

jq_filter_artists=""
while read -r artist; do
    jq_filter_artists+="\"${artist//\"/\\\"}\", "
done <<< "$blacklisted_artists"
jq_filter_artists="${jq_filter_artists%, }"

output(){
    jq -r ".items[] | select(.track.artists[].name == ($jq_filter_artists)) | .track.uri" <<< "$output"
}

while not_null "$url_path"; do
    output="$("$bash_tools/spotify/spotify_api.sh" "$url_path" "$@")"
    die_if_error_field "$output"
    url_path="$(get_next "$output")"
    output
done |
"$bash_tools/spotify/spotify_delete_from_playlist.sh" "Discover Backlog"
#tee >/dev/null \
#   >("$bash_tools/spotify/spotify_delete_from_playlist.sh" "Discover Backlog")
#   >("$bash_tools/spotify/spotify_uri_to_name.sh") \
