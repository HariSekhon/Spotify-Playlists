#!/usr/bin/env bash
#  vim:ts=4:sts=4:et
#
#  Author: Hari Sekhon
#  Date: 2013-05-16 19:32:36 +0100 (Thu, 16 May 2013)
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

#echo "Removing old normalized lists"
#find . -type f -name '.*' -maxdepth 1 -exec echo rm -v {} \;
echo "
Creating new normalized lists
"
playlists="$(find . blacklists -type f -maxdepth 1 |
             sed 's/^\.\///' |
             grep -vi -e '^\.' \
                      -e '/\?\.' \
                      -e '\.sh' \
                      -e '\.pl' \
                      -e '\.txt' \
                      -e '\.git' \
                      -e '\.orig' \
                      -e 'TODO' \
                      -e "tocheck" |
             sort -t '/' -k2nf)"

max_len=0
while read -r playlist; do
    [ ${#playlist} -gt $max_len ] &&
        max_len=${#playlist}
done <<< "$playlists"

while read -r playlist; do
    dirname="$(dirname "$playlist")"
    if [ "$dirname" = "." ]; then
        dirname=""
    else
        dirname="$dirname/"
    fi
    basename="$(basename "$playlist")"
    printf "generating normalized playlist %-${max_len}s => %s\\n" "$playlist" "$dirname.$basename"
    spotify/normalize_tracknames.pl "$playlist" > "$dirname.$basename"
done <<< "$playlists"
echo "
===================================== DONE =====================================
"
