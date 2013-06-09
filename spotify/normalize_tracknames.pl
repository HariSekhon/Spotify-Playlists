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
    s/\s+(?:-\s+(?:\(|")?|\(|\[)
        (?:
            (?:
                \d{1,4}"?(?:\s-)?|
                New|
                US|
                UK
            )\s+
        )?
        (?:
            (?:Digital(?:ly)?\s|Re-recorded\s+\/\s+)?Re-?master(?:ed)?|
            (?:LP\s*\/?\s*)?(?:\w+)?(?:'|")?(?:\w+)?\s+Version|
            (?:Mainstream\s+|Re-)?Edit|
            (?:as )?made\s+famous|
            Album|
            Amended|
            Bonus\s+Track|
            (?:Super\s+)?Clean|
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
            Stereo|
            Studio Recording|
            Mono|
            Juke[\s-]?Box
        )\b
        # TODO: replace (Unavailable in GB)$
        (?:[:;\s\)\]].*)?
        $//xi;
    s/( - .+) - Live$/$1/i;
    # cuts down on variations to just strip all apostrophes since a lot of compilation song names don't get them right
    #s/'\s/ /g;
    s/'/ /g;
    s/\?*$//;
    #s/rmx/Remix/i;
    # added extraction of featuring => artist
    # throwing away the first match to make sure I don't hit $1 from above in case there is no featuring
    s/()(?:\s+-\s+|\(|\[|\s+|,)(?:feat(?:\.|uring)|duet(?:\s+with)?|co-starring)\s+(\w+[\w-]?\w+(?:\s+\w+[\w-]\w+)*|[^\]\)-]+)(?:(?:\)|\])\s*)?/ /i;
    my $featuring;
    my @featuring;
    if($2){
        $featuring = $2;
        $featuring = trim($featuring);
        @featuring = split(/(?:and|\&)/i, $featuring);
        #$featuring =~ s/(?:and|\&)//;
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
    my @artists = split(/,|&|with|and/i, $artists);
    foreach(my $i=0; $i < scalar @artists; $i++){
        $artists[$i] = trim($artists[$i]);
    }
    $artists    = join(",", uniq_array(@artists));
    my $normalized_trackname="$diff$artists - " . trim($parts[1]);
    print STDERR "WARNING normalized artist is empty: '$_' => '$normalized_trackname'\n" unless $artists;
    print STDERR "WARNING normalized track name is empty: '$_' => '$normalized_trackname'\n" unless $parts[1];
    print STDERR "WARNING normalized trackname < 7 chars: '$normalized_trackname'\n" if(length($normalized_trackname) < 7);
    print "$normalized_trackname\n";
}

if(@files){
    foreach my $file (@files){
        open(my $fh, $file) or die "Failed to open file '$file': $!\n";
        while(<$fh>){ normalize($_) }
    }
} else {
    while(<STDIN>){ normalize($_) }
}
