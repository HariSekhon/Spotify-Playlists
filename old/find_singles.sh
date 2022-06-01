#!/usr/bin/env bash
#  vim:ts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2012-05-21 15:21:50 +0100 (Mon, 21 May 2012)
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

find_singles(){
    [ -d "$1" ] && return
    [[ "$1" =~ .*\.sh ]] && return
    echo "* Singles in $1:"
    grep -E "^[^-]+ - (.+) ==album==> $1$" < "$1" | sort
    echo
    echo
}

if [ -n "$1" ]; then
    for x in "$@"; do
        find_singles "$x"
    done
else
    for x in *; do
        find_singles "$x"
    done
fi
