#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-07-19 12:07:15 +0100 (Thu, 19 Jul 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

set -e
set -u
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$srcdir" || { echo "Failed to cd to '$srcdir'"; exit 1; }

"$srcdir/paste_playlists.sh" $@
#read -p "Press enter to process with dumping of track names"
playlists="$@"
if [ -z "$playlists" ]; then
    playlists_unordered="$(sed 's/#.*//' < "playlists_unordered.txt")"
    playlists_ordered="$(sed 's/#.*//' < "playlists_ordered.txt")"
    playlists="$playlists_ordered $playlists_unordered"
fi
playlists_changed="$(hg st -A $playlists | grep -v -e "^[CI]" | sed 's/..//' )"
if [ -n "$playlists_changed" ]; then
    "$srcdir/dump_playlists.sh" -a $playlists_changed
else
    echo "No playlist changed, skipping re-dump"
fi
