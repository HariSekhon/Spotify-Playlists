#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-13 23:44:04 +0100 (Mon, 13 May 2013)
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

md5s="$(md5 $(ls blacklists/* | grep '^blacklists/[[:digit:]]\+$' | sed 's,blacklists/,blacklists / ,;s/)/ )/' | sort -k3n | sed 's,blacklists / ,blacklists/,;s/ )/)/') )"
dups="$(sed 's/.* = //' <<< "$md5s" | sort | uniq -d )"
for dup in $dups; do
    num=0
    while read MD5 filename equals md5; do
        let num+=1
        [ $num -eq 1 ] && continue
        filename="${filename#(}"
        filename="${filename%)}"
        rm -vf "$filename" "../$filename"
    done <<< "$(fgrep "$dup" <<< "$md5s")"
    let num-=1
    if [ $num -eq 1 ]; then
        echo "removed $num duplicate of $dup"
    else
        echo "removed $num duplicates of $dup"
    fi
done
