#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-20 02:41:26 +0100 (Mon, 20 May 2013)
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
pushd "$srcdir" >/dev/null || { echo "Failed to pushd to '$srcdir'"; exit 1; }
ls blacklists/[[:digit:]]* | sed 's,blacklists/,,' | while read blacklist; do
    playlist="../blacklists/.$blacklist.album"
    [ -f "$playlist" ] || { echo "blacklist file '$playlist' not found"; continue; }
    artist_counts="$(perl -p -e 's/\s+-\s+.*//' < "$playlist" | sort | uniq -c | sort -k1nr)"
    artist_top="$(awk '{print $1; exit}' < "$artist_counts")"
    artist_total="$(awk 'BEGIN{sum=0}{sum+=$1}END{print $sum}' < "$artist_counts")"
    artists_pc="$(awk "{print $artist_top / $artist_total; if }" < /dev/null)"
    album="$(sed 's/.*\[Album://;s/\]$//' < "$playlist" | sort -u)"
    if [ "$(wc -l <<< "$album" | awk '{print $1}')" -eq 1 ]; then
        if [ "$(wc -l <<< "$artist" | awk '{print $1}')" -eq 1 ]; then
            echo "$artist - $album"
        else
            echo "Various Artists - $album"
        fi
    fi
done | tee blacklists/index.txt
popd >/dev/null
