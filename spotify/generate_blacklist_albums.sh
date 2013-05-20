#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2013-05-20 02:33:32 +0100 (Mon, 20 May 2013)
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
pushd "$srcdir/blacklists" >/dev/null || { echo "Failed to pushd to '$srcdir/blacklists'"; exit 1;}

echo "Generating blacklist album files to $srcdir/../blacklists/.\$blacklist.album"
ls [[:digit:]]* | sort -n | while read x; do echo "generating album playlist blacklists/$x"; spotify-lookup.pl --album "$x" > ../../blacklists/.$x.album; done
echo "
===================================== DONE =====================================
"
popd >/dev/null
