#!/usr/bin/perl -T
#
#   Author: Hari Sekhon
#   Date: 2013-05-14 18:53:30 +0100 (Tue, 14 May 2013)
#  $LastChangedBy$
#  $LastChangedDate$
#  $Revision$
#  $URL$
#  $Id$
#
#  vim:ts=4:sts=4:et

$VERSION = "0.1";

use strict;
use warnings;
use File::Basename;

# because my hg command on Mac is found in /usr/local/bin
$ENV{'PATH'} = "/bin:/usr/bin:/usr/local/bin";
delete $ENV{'ENV'};

my $srcdir            = dirname(__FILE__);
my $blacklistdir      = "$srcdir/blacklists";
my $blacklisttrackdir = "$srcdir/../blacklists"; 
chdir($blacklistdir) or die "Failed to chdir to $blacklistdir";

opendir my $fh, "." or die "Can't opendir blacklist dir '$blacklistdir': $!\n";
my @filelist;
foreach(readdir($fh)){
    if(/^(\d+)$/){
        push(@filelist, $1);
    }
}

# Only working on number files
@filelist = sort { $a <=> $b } grep { $_ =~ /^\d+$/ } @filelist;
#print "filelist:\n";
#foreach(@filelist){
#    print "$_\n";
#}

my %fileslots;

foreach(my $i=1;$i<=$filelist[-1];$i++){
    if ( -e "$i"){
        $fileslots{$i} = "1";
    }
}

foreach my $i (@filelist){
    my $next_free_slot = 0;
    my @slots = sort { $a <=> $b } keys %fileslots;
    my $highest_slot = $slots[-1];
    foreach(my $j=1; $j < $highest_slot; $j++){
        ( -e "$j" ) and next;
        $next_free_slot = $j;
        last;
    }
    if($next_free_slot eq 0){
        print "Nothing to compact\n";
        exit 0;
    }
    next if ($next_free_slot ge $i);

    if ( $i ne $next_free_slot ){
        system("echo hg mv -v '$i' '$next_free_slot'") and die "Failed to move $i => $next_free_slot";
        system("echo hg mv -v '$blacklisttrackdir/$i' '$blacklisttrackdir/$next_free_slot'") and die "Failed to move tracks $i => $next_free_slot";
        $fileslots{$next_free_slot} = 1;
        delete $fileslots{$i};
    }
}
