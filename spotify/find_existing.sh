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

die(){
    echo "$@"
    exit 1;
}

cd "$srcdir" || die "failed to cd to '$srcdir'"

find_existing(){
    for x in $@; do
        [ -f "$x" ] || die "File not found: '$x'"
    done
    echo "* Existing tracks from $1: (in "${@:2}")"
    while read line; do
        grep -q "^$line$" ${@:2} &&
            echo "$line"
    done < "$1" #|
    # Don't do this here, I can just pipe to spotify-lookup.pl if need be
    #spotify-lookup.pl | sort -f
    #echo
    #echo
}

[ -n "${2:-}" ] || die "usage: ${0##*/} playlist grand_playlists"
find_existing $@
