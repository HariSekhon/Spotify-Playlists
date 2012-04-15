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
    spotify-lookup.pl -v -f "$1" | sort -f > "../$1.new"
    echo "Wrote ../$1.new"
    echo
}
if [ -n "$1" ]; then
    dump_playlist "$1"
else
    for x in *; do [ -d "$x" ] && continue; [[ "$x" =~ .*\.sh ]] && continue; dump_playlist "$x"; done
fi
