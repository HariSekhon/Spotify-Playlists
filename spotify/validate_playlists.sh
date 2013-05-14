#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-14 19:52:18 +0100 (Tue, 14 May 2013)
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

status=0 
validate_playlist(){
    local playlist="$1"
    local unrecognized_lines="$(egrep -v -e '^http://open.spotify.com/track/[A-Za-z0-9]{22}$' -e 'http://open.spotify.com/local/{1,3}[A-Za-z0-9\.\/\%\+-]+/[[:digit:]]{2,3}$' "$playlist")"
    if [ -n "$unrecognized_lines" ]; then
        echo "Playlist Invalid, unrecognized lines:"
        echo
        echo "$unrecognized_lines"
        echo
        echo
        status=1
    else
        echo "Playlist $playlist valid, all lines matched"
    fi
}

if [ -z "$@" ]; then
    for x in $(find . -type f | grep -vi -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck"); do
        validate_playlist "$x"
    done
else
    for x in $@; do
        validate_playlist "$x"
    done
fi
exit $status
