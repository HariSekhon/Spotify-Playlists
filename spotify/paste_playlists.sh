#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-04-12 20:14:36 +0100 (Thu, 12 Apr 2012)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sw=4:et

srcdir=$(dirname $(which $0))
cd "$srcdir" || exit 1;
sorted_files="
chill
classical
classics-archive
current_mix
dance
dt8-trance
electronica
fitness-first
jazz
kiss
love
rock
workout
"
unsorted_files="
hangout-rnb
jay-z
"
for x in $sorted_files; do echo "Paste $x:"; cat | sort -f > "$x"; ./find_dups.sh "$x"; echo; echo; done
for x in $unsorted_files; do echo "Ordered Paste $x:"; cat > "$x"; ./find_dups.sh "$x"; echo; echo; done
