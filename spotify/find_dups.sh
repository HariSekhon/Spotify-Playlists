#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:10:24 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1

find_dups(){
    [ -d "$1" ] && return
    [[ "$1" =~ .*\.sh ]] && return
    echo "Duplicates in $1:"
    uniq -d < "$1" | spotify-lookup.pl
    echo
    echo
}

if [ -n "$1" ]; then
    for x in $@; do
        find_dups "$x"
    done
else
    echo ELSE
    for x in *; do
        find_dups "$x"
    done
fi
