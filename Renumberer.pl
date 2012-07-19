#!/usr/bin/perl -w
use strict;
use File::Slurp;
# THIS IS FOR ITERATING THROUGH A CONFIG FILE TO FIND A MEMCACHE ARRAY,
# THEN REMOVING A HOST FROM THE ARRAY AND RENUMBERING THE OTHER MEMBERS

unless ($ARGV[0]) {
    die "Error - need to give me a file to use, ya numpty\n";
}

my $workingFile = $ARGV[0];
my $outFile = $workingFile . ".CLEAN";

print "FILE IS $workingFile and OUTFILE is $outFile\n";

my $hostToRemove = "10.10.5.54";
my $fileAsString = read_file("$workingFile");
open(FILE, ">$outFile") || die "Ouch, dead! Cannae open file\n";

my @outfileText;

sub extractMemcacheSection {
    my $txt = shift;
    if ($txt =~ m/(.*?)(\'[a-z]+\.memcached\.servers\' => array\(.*?\),)(.*)/sm) {
        push(@outfileText,$1);
        print "ORIG: $2\n";
        my $cleanMemcacheArray = removeHost($2);
        print "ClEAN: $cleanMemcacheArray\n";
        push(@outfileText,$cleanMemcacheArray);
        if (length($3) > 0) {
            extractMemcacheSection($3);
        }
    } else {
        push(@outfileText,$txt);
    }
}

sub removeHost {
    my @txtarray = split('\n', shift);
    my @hosts;
    my @returnText;
    foreach my $line(@txtarray) {
        if ($line =~ /memcach.*/) { $line = $line . "\n"; push (@returnText,$line); }
        if ($line =~ /(10.10.\d{1,3}.\d{1,3}:11211)/) {
            push(@hosts,$1);
        }
    }
    my @newHosts = grep { !/$hostToRemove/ } @hosts;
    for my $i (0 .. $#newHosts) {
            my $line = "               $i => \'$newHosts[$i]\',\n";
            push (@returnText,$line);
    }
    push(@returnText,"        ),");
    my $cleanedArray = join "", @returnText;
}

extractMemcacheSection($fileAsString);
print FILE @outfileText;
close(FILE);
