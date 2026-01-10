#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-23 18:02:26 +0100 (Thu, 23 Jul 2020)
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

# playlist ID obtained from 'SPOTIFY_PRIVATE=1 bash-tools/spotify/spotify_playlist_name_to_id.sh Driving'
# can also be obtained from in private/spotify/playlists.txt
playlist_id="7EbcD860xd91FE1zOF3F3E"

url_path="/v1/playlists/$playlist_id/tracks"

# requires authorized token
export SPOTIFY_PRIVATE=1

spotify_token

clear_playlist(){
    timestamp "clearing driving playlist"
    # uris field needs to be blank for this to work, not really optional like doc implies
    "$srcdir/bash-tools/spotify/spotify_api.sh" "$url_path" -X PUT -d '{"uris": []}' > /dev/null  # ignore the { "spotify_snapshot": ... } json output
}

"$srcdir/backup.sh" "Upbeat & Sexual Pop"

clear_playlist

"$srcdir/bash-tools/spotify/spotify_add_to_playlist.sh" "$playlist_id" < <(tail -r "$srcdir/spotify/Upbeat & Sexual Pop")

timestamp "Regenerated driving playlist in $SECONDS seconds"
