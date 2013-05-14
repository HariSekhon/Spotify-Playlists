#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-14 20:08:36 +0100 (Tue, 14 May 2013)
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

status=0 
validate_playlist_length(){
    local playlist="$1"
    local tracklist="../$playlist"
    [ -f "$playlist" ] || { echo "File not found: '$playlist'"; exit 1; }
    [ -f "$tracklist" ] || { echo "File not found: '$tracklist'"; exit 1; }
    playlist_wc=$(wc -l "$playlist" | awk '{print $1}')
    tracklist_wc=$(wc -l "$tracklist" | awk '{print $1}')
    if [ "$playlist_wc" != "$tracklist_wc" ]; then
        echo "Playlist $playlist dump invalid, mismatching number of lines ($playlist_wc vs $tracklist_wc)"
        status=1
    fi
}

if [ -z "$@" ]; then
    for x in $(find . -type f | grep -vi -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck"); do
        validate_playlist_length "$x"
    done
else
    for x in $@; do
        validate_playlist_length "$x"
    done
fi
exit $status
