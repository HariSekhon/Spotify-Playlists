#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-16 19:32:36 +0100 (Thu, 16 May 2013)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sts=4:et

set -e
set -u
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$srcdir" || { echo "failed to cd to '$srcdir'"; exit 1; }

#echo "Removing old normalized lists"
#find . -type f -name '.*' -maxdepth 1 -exec echo rm -v {} \;
echo "Creating new normalized lists"
playlists="$(find . blacklists -type f -maxdepth 1 | sed 's/^\.\///' | grep -vi -e "^/\?\." -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck")"

max_len=0
while read playlist; do
    [ ${#playlist} -gt $max_len ] &&
        max_len=${#playlist}
done <<< "$playlists"

while read playlist; do
    dirname="$(dirname "$playlist")"
    if [ "$dirname" = "." ]; then
        dirname=""
    else
        dirname="$dirname/"
    fi
    basename="$(basename "$playlist")"
    printf "generating normalized playlist %-${max_len}s => %s\n" "$playlist" "$dirname.$basename"
    spotify/normalize_tracknames.pl "$playlist" > "$dirname.$basename"
done <<< "$playlists"
echo "
===================================== DONE =====================================
"
