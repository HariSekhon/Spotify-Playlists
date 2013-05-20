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
    album="$(sed 's/.*\[Album://;s/\]$//' < "../blacklists/.$blacklist.album" | sort -u)";
    if [ "$(wc -l <<< "$album" | awk '{print $1}' | wc -l)" -eq 1 ]; then
        echo "$album"
    fi
done | tee blacklists/index.txt
popd >/dev/null
