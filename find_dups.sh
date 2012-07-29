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
    [ -f "$1" ] || { echo "Error: no such file '$1'"; return 1; }
    echo "* Duplicates in $1:"
    tr 'A-Z' 'a-z' < "$1" | 
    # (.* catches (feat. Blah) and Dirty catches Diddy - Dirty Money so can't use those
    #perl -p -e 's/(?:\s+\-)?\s+(\((?:as )?made famous|(Album|Single|Clean|Explicit|Amended|(?:\d+\s+)?Re-?master)|\[theme from).*$//i' |
    # Keep this updated from spotify/find_missing.sh
    perl -pne 's/^The //i; s/ - \(?(?:\d{2,4}\s+)?(?:(?:UK )?Radio|(?:Digital )?Re-?master(?:ed)?|Single|Album|Amended|Main|Uncut|Edit|Explicit|Clean|Mix|Original|Re-edit|Bonus Track|'"'"'?\w+ Version|(?:as )?made famous|theme from)([\s\)].*)?$//i' |
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
