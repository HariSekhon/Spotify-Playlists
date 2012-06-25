#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-05-21 15:21:50 +0100 (Mon, 21 May 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1

find_singles(){
    [ -d "$1" ] && return
    [[ "$1" =~ .*\.sh ]] && return
    echo "* Singles in $1:"
    egrep '^[^-]+ - (.+) ==album==> $1$' < "$1" | sort
    echo
    echo
}

if [ -n "$1" ]; then
    for x in $@; do
        find_singles "$x"
    done
else
    for x in *; do
        find_singles "$x"
    done
fi
