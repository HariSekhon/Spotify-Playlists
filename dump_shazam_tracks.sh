#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-06-04 19:04:23 -0700 (Mon, 04 Jun 2012)
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
cd "$srcdir" || { echo "Failed to cd to $srcdir"; exit 1; }

sqlite3 $HOME/Downloads/Shazam-rip-from-phone/Documents/ShazamDataModel.sqlite <<< "select a.zname, b.zname from ZSHARTISTMO a, ZSHTAGRESULTMO b where a.ZTAGRESULT = b.Z_PK;" > Shazam-dump-$(date +%F).txt
