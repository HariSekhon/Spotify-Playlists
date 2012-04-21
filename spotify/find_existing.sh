#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-21 22:00:45 +0100 (Sat, 21 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

set -e
set -u
srcdir=$(dirname $(which $0))

find_existing(){
    echo "* Existing tracks from $1: (in "${@:2}")"
    while read line; do
        grep -q "^$line$" ${@:2} &&
            echo "$line"
    done < "$1" |
    spotify-lookup.pl | sort -f
    echo
    echo
}

find_existing $@
