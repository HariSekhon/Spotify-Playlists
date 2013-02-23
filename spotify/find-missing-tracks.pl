#!/usr/bin/perl -T
#
#  Author: Hari Sekhon
#  Date: 2013-02-23 21:54:53 +0000 (Sat, 23 Feb 2013)
#  Original Date: 2012-04-15 20:37:10 +0100 (Sun, 15 Apr 2012)
#
#  vim:ts=4:sw=4:et

$DESCRIPTION = "Finds tracks in given playlist that doesn't appear in the other playlists. Quick port of a shell version I kept for too long

Useful for finding tracks you want to keep in multiple playlists by checking if the tracks from the given current playlists exist in at least one of the grand playlists

I use this especially to make sure my grand genre playlists contain all the songs from all my more specialised playlists

By default it will use ./current_playlists.txt and ./grand_playlist.txt if non are specified on the command line";

$VERSION = "0.1";

use strict;
use warnings;
BEGIN {
    use File::Basename;
    use lib dirname(__FILE__) . "/lib";
}
use HariSekhonUtils;

my $no_lookup = 0;
my $no_translate = 0;
my $current_playlists;
my $grand_playlists;
my $additional_grand_playlists;
my $no_locking = 0;
my $quiet = 0;
$verbose = 1;

my $current_playlists_file = dirname(__FILE__) . "/current-playlists.txt";
my $grand_playlists_file = dirname(__FILE__) . "/grand-playlists.txt";

sub slurp_to_array($){
    my $fh = open_file $current_playlists_file;
    my @arr;
    while(<$fh>){
        chomp;
        s/#.*$//;
        /^\s*$/ and next;
        push @arr, $_;
    }
    close $fh;
    return @arr;
}

my @current_playlists_default = slurp_to_array($current_playlists_file) if( -r $current_playlists_file );
my @grand_playlists_default   = slurp_to_array($grand_playlists_file)   if( -r $grand_playlists_file );

%options = (
    "s|spotify-uri"         =>  [   \$no_translate,     "Output Spotify URIs for pasting back in to spotify" ],
    "n|nolookup"            =>  [   \$no_lookup,        "Don't translate at all, don't use spotify-lookup.pl to check artist - song (weakens matching. Only use when spotify-lookup.pl is broken). Also enables -spotify-uri" ],
    "g|grand-playlists=s"   =>  [   \$grand_playlists,  "Playlists to check against" ],
    "a|aditional-grand-playlists=s" => [ $additional_grand_playlists, "Additional playlists to check on top of default list taken from: $grand_playlists_file" ],
    "no-locking"            =>  [   \$no_locking,       "Set no locking on spotify-lookup.pl" ],
    "q|quiet"               =>  [   \$quiet,            "Quiet mode" ],
);

$usage_line = "usage: $progname [ options ] -g 'grand_playlist1 grand_playlist2 ...' playlist1 playlist2 ...";
@usage_order = qw/spotify-uri nolookup additional-grand-playlists grand-playlists no-locking verbose quiet/;
get_options();

$verbose -= 1 if $quiet;

if($no_lookup){
    $no_lookup = 1;
    $no_translate = 1;
}

vlog2;
set_timeout();

if(@ARGV){
    $current_playlists .= " $_";
}

@current_playlists = uniq_array split(/\s*/, $current_playlists_default) if $current_playlists;
usage "no playlists specified and non found from default location '$current_playlists_default'" unless(@current_playlists);

@grand_playlists = split(/\s*/, $grand_playlists_default) if $grand_playlists;

if($additional_grand_playlists){
    foreach(split(/\s*/, $additional_grand_playlists)){
        push(@grand_playlists, $_);
    }
}
@grand_playlists = uniq_array @grand_playlists;

usage "no grand playlists specified and non found from default location '$grand_playlists_default'" unless(@grand_playlists);

my @grand_tracks;
foreach(@grand_playlists){
    my $fh = open_file $_;
    push(@grand_tracks, <$fh>);
    @grand_tracks = uniq_array @grand_tracks;
}

sub find_missing_tracks($){
    my $playlist = shift;
    vlog "* Missing tracks in $1: (not found in "${2# }")";
    my $fh = open_file $playlist;
     
    my @found_tracks;
    my @missing_tracks;
    while my $track (<$fh>){
        if(grep { lc $track eq lc $_ } @grand_tracks){
            push(@found_tracks, $track);
        } else {
            push(@missing_tracks, $track)
        }
    }
    if($no_translate){
    }
}

foreach(@current_playlists){
    find_missing_tracks($_);
}
