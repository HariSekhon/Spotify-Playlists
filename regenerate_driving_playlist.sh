#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-23 18:02:26 +0100 (Thu, 23 Jul 2020)
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
. "$srcdir/bash-tools/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Regenerates the Driving playlist as the reverse of the Upbeat & Sexual Pop playlist so that newest tracks are at the top in the mobile player

$usage_auth_msg

$usage_token_private
"

help_usage "$@"

# playlist ID obtained from 'SPOTIFY_PRIVATE=1 bash-tools/spotify_playlist_name_to_id.sh Driving'
# can also be obtained from in private/spotify/playlists.txt
url_path="/v1/playlists/7EbcD860xd91FE1zOF3F3E/tracks"

# requires authorized token
export SPOTIFY_PRIVATE=1

spotify_token

spotify_api="$srcdir/bash-tools/spotify_api.sh"

declare -a ids
ids=()

clear_playlist(){
    timestamp "clearing driving playlist"
    # uris field needs to be blank for this to work, not really optional like doc implies
    "$spotify_api" "$url_path" -X PUT -d '{"uris": []}'
    echo
}

add_to_playlist(){
    if [ $# -lt 1 ]; then
        echo "Error: no IDs passed to add_to_playlist()" >&2
    fi
    local id_array=""
    for id in "$@"; do
        # requires explicit track URI type since could also be episodes added to playlist
        id_array+="\"spotify:track:$id\", "
    done
    id_array="${id_array%, }"
    timestamp "adding ${#@} tracks to driving playlist"
    "$spotify_api" "$url_path" -X POST -d '{"uris": '"[$id_array]}"
    echo
    #tr ',' '\n' <<< "$ids"
    ((num+=${#@}))
}

clear_playlist

num=0

while read -r track_uri; do
    if is_blank "$track_uri"; then
        continue
    fi
    if is_local_uri "$track_uri"; then
        continue
    fi
    id="$(validate_spotify_uri "$track_uri")"

    ids+=("$id")

    if [ "${#ids[@]}" -ge 50 ]; then
        add_to_playlist "${ids[@]}"
        ids=()
    fi
done < <(tail -r "$srcdir/spotify/Upbeat & Sexual Pop")

add_to_playlist "${ids[@]}"

timestamp "Regenerated driving playlist with $num tracks"
