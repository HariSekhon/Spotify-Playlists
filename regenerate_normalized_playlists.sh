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
find . blacklists -type f -maxdepth 1 | grep -vi -e "\.sh" -e "\.pl" -e "\.txt" -e "\.svn" -e "\.orig" -e "TODO" -e "tocheck" | sed 's/^\.\///' | while read x; do echo "generating normalized playlist $x => .$x"; spotify/normalize_tracknames.pl "$x" > ".$x"; done
