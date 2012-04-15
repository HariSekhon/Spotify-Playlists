#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:09:18 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1
dump_playlist(){
    [ -d "$1" ] && return
    [[ "$1" =~ .*\.sh ]] && return
    spotify-lookup.pl -v -f "$1" | sort -f > "../$1"
    echo "Wrote ../$1"
    echo
    echo
}

start=$(date +%s)
if [ -n "$1" ]; then
    for x in $@; do
        dump_playlist "$x"
    done
else
    for x in *; do
        dump_playlist "$x"
    done
fi
stop=$(date +%s)
let total_secs=$stop-$start
echo
echo "Playlist dumping completed in $total_secs secs"
