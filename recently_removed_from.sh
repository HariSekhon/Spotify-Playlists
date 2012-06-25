#!/usr/bin/env bash
#
#   Author: Hari Sekhon
#   Date: 2012-06-16 13:51:42 +0100 (Sat, 16 Jun 2012)
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
cd "$srcdir" || { echo "failed to cd to '$srcdir'"; exit 1; }

svn diff | grep -i -e "$*" -e "+++" | grep -i "$*" -B1
