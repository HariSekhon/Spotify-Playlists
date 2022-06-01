#!/usr/bin/env bash
#  vim:ts=4:sts=4:et
#
#  Author: Hari Sekhon
#  Date: 2013-05-14 19:52:18 +0100 (Tue, 14 May 2013)
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

cd "$srcdir"

status=0
validate_playlist(){
    local playlist="$1"
    [ -f "$playlist" ] || { echo "File not found: $playlist"; exit 1; }
    local unrecognized_lines
    unrecognized_lines="$(grep -Ev -e '^spotify:track:[A-Za-z0-9]{22}$' \
                                   -e '^spotify:local:{1,3}[A-Za-z0-9\.\/:\%\+-]+:[[:digit:]]{2,3}$' "$playlist")"
    if [ -n "$unrecognized_lines" ]; then
        echo "Playlist Invalid, unrecognized lines:"
        echo
        echo "$unrecognized_lines"
        echo
        echo
        status=1
    else
        echo "Playlist $playlist valid, all lines matched"
    fi
}

if [ -z "$*" ]; then
    while read -r line; do
        validate_playlist "$line"
    done < <(find . -type f | grep -vi -e '\.sh' -e '\.pl' -e '\.txt' -e '\.svn' -e '\.orig' -e 'TODO' -e 'tocheck')
else
    for x in "$@"; do
        validate_playlist "$x"
    done
fi
exit $status
