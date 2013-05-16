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

for blacklist in blacklists/*; do
    [ -f "../$blacklist" ] || continue
    if [ "`wc -l "$blacklist" | awk '{print $1}'`" != "`wc -l "../$blacklist" | awk '{print $1}'`" ]; then
        echo "ERROR: $blacklist wc -l != ../$blacklist wc -l"
        exit 1
    fi
done

# Wanted to check ../blacklists/ for dups as well but tracknames change so often as to render that useless
# Even this will miss a lot
# TODO: consider switching this from md5 to diff two playlists of same length and if more than 90% similarity exclude
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
    echo -n "removed $num duplicate"
    if [ $num -ne 1 ]; then
        echo -n "s"
    fi
    echo " of $(grep "$dup" <<< "$md5s" | head -n1 | awk '{print $2" "$4}')"
done
