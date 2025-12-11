#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-07-05 02:57:34 +0100 (Sun, 05 Jul 2020)
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

bash_tools="$srcdir/bash-tools"

# shellcheck disable=SC1090,SC1091
. "$bash_tools/.bash.d/git.sh"

cd "$srcdir"

"$bash_tools/scripts/spotify_commit_playlists.sh" "$@"

if [ -n "$*" ]; then
    exit 0
fi

# commit .description and .txt files
commit_other_files(){
    local filenames=()
    while read -r filename; do
        filenames+=("$filename")
    done < <(
        git status --porcelain |
        grep -E '^.M[[:space:]]' |
        cut -c 4- |
        sed 's/^"//; s/"$//' |
        grep -E -e '\.description$' -e '\.txt$'
    )

    if [ -n "${filenames:-}" ]; then
        for filename in "${filenames[@]}"; do
            gitu "$filename"
        done
    fi
}

commit_other_files

if [ -d "$srcdir/private" ]; then
    cd "$srcdir/private"

    "$bash_tools/scripts/spotify_commit_playlists.sh" "$@"

    commit_other_files
fi
