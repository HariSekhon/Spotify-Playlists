#!/usr/bin/env bash
#  vim:ts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2012-06-04 19:04:23 -0700 (Mon, 04 Jun 2012)
#

set -eu
srcdir="$(dirname "${BASE_SOURCE[0]}")"

cd "$srcdir"

# use iPhone Explorer on Mac to copy the /Apps/Shazam folder entirely to Downloads/Shazam-rip-from-phone, free version doesn't allow mounting so that step has to be manual unfortunately
sqlite3 ~/Downloads/Shazam-rip-from-phone/Documents/ShazamDataModel.sqlite <<< "select a.zname, b.zname from ZSHARTISTMO a, ZSHTAGRESULTMO b where a.ZTAGRESULT = b.Z_PK;" > "Shazam-dump-$(date '+%F').txt"
