#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-04 13:14:15 +0100 (Sat, 04 Jul 2020)
#
#  https://github.com/harisekhon/playlists
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
. "$srcdir/bash-tools/.bash.d/git.sh"

merge(){
    mv -f "$1" "$2"
    cd spotify
    mv -f "$1" "$2"
    cd ..

    ./commit.sh "$2"

    gitrename "$2" "$1"

    cd spotify

    gitrename "$2" "$1"
}

if [ $# -gt 0 ]; then
    merge "$1" "$2"
else
    git st --porcelain |
    grep '^??' |
    cut -d" " -f 2- |
    sed 's/spotify\///'|
    sort -u |
    while read -r filename; do
        if [ -f "spotify/${filename// /_}" ]; then
            merge "$filename" "${filename// /_}"
            read -r -p "Press Enter to continue"
        fi
    done
fi
