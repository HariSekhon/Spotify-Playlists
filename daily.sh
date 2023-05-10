#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-10-30 17:43:50 +0000 (Fri, 30 Oct 2020)
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
. "$srcdir/bash-tools/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Run daily maintenance - Backup Playlists, then load Discover Backlog and dedupe
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

{

help_usage "$@"

# get Spotify credentials and SSH agent credentials
for x in ~/.bash_vars ~/.agent.env; do
    if [ -f "$x" ]; then
        # shellcheck disable=SC1090
        . "$x"
    fi
done

cd "$srcdir"

# doesn't commit but needed for full dedupe
make backups 2>&1 | tee "$srcdir/backup.log"

SPOTIFY_ACCESS_TOKEN="$(SPOTIFY_PRIVATE=1 ./bash-tools/spotify/spotify_api_token.sh)"
export SPOTIFY_ACCESS_TOKEN

./discover_backlog_load.sh 2>&1 | tee "$srcdir/discover_backlog_load.log" || :


# do 2 more attempts because the Spotify API often breaks for extended periods of time with 500 errors
./discover_backlog_dedupe.sh 2>&1 | tee "$srcdir/discover_backlog_dedupe.log" || :

# wait a while and do another pass as the backlog is several thousand tracks which is a large window to be hit with a 500 error outage on the Spotify API
sleep 300

./discover_backlog_dedupe.sh 2>&1 | tee -a "$srcdir/discover_backlog_dedupe.log"

} 2>&1 | tee "$srcdir/daily.log"
