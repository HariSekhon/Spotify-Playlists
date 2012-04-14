#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:09:18 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1
for x in *; do [ -d "$x" ] && continue; [[ "$x" =~ .*\.sh ]] && continue; spotify-lookup.pl -v -f "$x" | sort -f > "../$x.new"; done
