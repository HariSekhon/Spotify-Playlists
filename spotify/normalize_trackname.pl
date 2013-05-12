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

use strict;
use warnings;

s/^The //i;
s/\s(?:-\s(?:\(|")?|\()
    (?:
        (?:
            \d{1,4}"? |
            New |
            US |
            UK
        )\s+
    )?
    (?:
        Radio|(?:Digital\s)?Re-?master(?:ed)?|
        Single|
        Album|
        Amended|
        Main|
        Uncut|
        (?:Mainstream |Re-)?Edit|
        Explicit|
        Clean|
        Mix|
        Original|
        Bonus Track|
        '?\w+ Version|
        (?:as )?made famous|
        theme from|
        from|
        Full length
    )
    ([\s\)].*)?
    $//xi;
s/( - .+) - Live$/$1/i
