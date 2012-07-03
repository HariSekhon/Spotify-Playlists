#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-15 19:31:27 +0100 (Sun, 15 Apr 2012)
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
    echo "* Duplicates in $1:"
    tr 'A-Z' 'a-z' < "$1" | 
    sed -r 's/[[:space:]](\(|(Album|Single|Clean|Dirty|Explicit|Amended|[[:digit:]]*[[:space:]]*Re-?master)).*$//i' |
    sort | uniq -d
    echo
    echo
}

if [ -n "$1" ]; then
    for x in $@; do
        find_dups "$x"
    done
else
    for x in *; do
        find_dups "$x"
    done
fi
