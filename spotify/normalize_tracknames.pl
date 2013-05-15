#!/usr/bin/perl -T
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

$DESCRIPTION="Normalize Track Names removing edit/version tags";

$VERSION="0.3";

use strict;
use warnings;
BEGIN {
    use File::Basename;
    use lib dirname(__FILE__) . "/lib";
}
use HariSekhonUtils;

my $file;
my @files;

%options = (
    "f|file=s"      => [ \$file, "File of track names to normalize. Takes a comma separated list of files. Uses STDIN if no files are specified" ],
);

get_options();

if($file){
    my @tmp = split(/\s*,\s*/, $file);
    push(@files, @tmp);
}

foreach(@ARGV){
    push(@files, $_);
}

( $file and not -f $file ) and die "Error: couldn't find file '$file'\n";
foreach my $file (@files){
    if(not -f $file ){
        print STDERR "File not found: '$file'\n";
        @files = grep { $_ ne $file } @files;
    }
}

vlog_options "files", "[ '" . join("', '", @files) . "' ]";

sub normalize ($) {
    chomp;
    # diff line removal
    /^(?:diff|[+-]{3}|\@\@) / and return;
    s/^([ +-])//;
    my $diff = $1 ? $1 : "";
    # original track name normalization
    s/^The //i;
    s/\s+(?:-\s+(?:\(|")?|\()
        (?:
            (?:
                \d{1,4}"?(?:\s-)?|
                New|
                US|
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
        (?:[\s\)].*)?
        $//xi;
    s/( - .+) - Live$/$1/i;
    #s/rmx/Remix/i;
    # added extraction of featuring => artist
    # throwing away the first match to make sure I don't hit $1 from above in case there is no featuring
    s/()(?:\s+-\s+|\()?feat(?:uring)?\.?\s+(.+)$//i;
    my $featuring;
    my @featuring;
    if(0){
        $featuring = $2;
        @featuring = split(/(?:and|\&)/, $featuring);
        $featuring =~ s/(?:and|\&)//;
    }
    my @parts   = split(" - ", $_, 2);
    my $artists = $parts[0];
    my $song    = $parts[1];
    #$artists or quit "CRITICAL", "artists string is blank for line '$_'";
    #$song    or quit "CRITICAL", "song string is blank for line '$_'";
    unless($artists and $song){
        vlog2 "skipping line '$_' since \$artists or \$song is blank";
        print "$_\n";
        return;
    }
    $artists =~ s/ duet with /,/;
    if(@featuring){
        $artists .= "," . join(",", @featuring);
    }
    my @artists = split(",", $artists);
    $artists    = join(",", sort @artists);
    print "$diff$artists - $parts[1]\n";
}

if(@files){
    foreach my $file (@files){
        open(my $fh, $file) or die "Failed to open file '$file': $!\n";
        while(<$fh>){ normalize($_) }
    }
} else {
    while(<STDIN>){ normalize($_) }
}
