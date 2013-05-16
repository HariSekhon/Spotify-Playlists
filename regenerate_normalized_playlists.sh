#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-16 19:32:36 +0100 (Thu, 16 May 2013)
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

#echo "Removing old normalized lists"
#find . -type f -name '.*' -maxdepth 1 -exec echo rm -v {} \;
echo "Creating new normalized lists"
find . blacklists -type f -maxdepth 1 | grep -vi -e "/\." -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck" | while read x; do dirname="$(dirname "$x")"; basename="$(basename "$x")"; echo "generating normalized playlist $x => $dirname/.$basename"; spotify/normalize_tracknames.pl "$x" > "$dirname/.$basename"; done
