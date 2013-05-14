#!/usr/bin/perl -Tp
#
#   Author: Hari Sekhon
#   Split off from find_missing.sh
#   Date: 2013-05-12 22:35:49 +0100 (Sun, 12 May 2013)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sts=4:et

# TODO: turn this in to a propper program with cli args etc

$VERSION="0.1";

use strict;
use warnings;

s/^The //i;
s/\s+(?:-\s+(?:\(|")?|\()
    (?:
        (?:
            \d{1,4}"? |
            New |
            US |
            UK
        )\s+
    )?
    (?:
        (?:Digital\s)?Re-?master(?:ed)?|
        (?:LP\s*\/?\s*)?(?:\w+)?(?:'|")?(?:\w+)?\s+Version|
        (?:Mainstream\s+|Re-)?Edit|
        (?:as )?made\s+famous|
        Album|
        Amended|
        Bonus\s+Track|
        Clean|
        Explicit|
        Full\s+length
        Live|
        Main|
        Mix|
        Original|
        Radio|
        Single|
        Uncut|
        from|
        theme\s+from|
    )
    ([\s\)].*)?
    \n$/\n/xi;
s/( - .+) - Live$/$1/i;
