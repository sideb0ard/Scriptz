#!/usr/bin/perl -w
use strict;
use File::Slurp;

my $hostToRemove = "10.10.5.54";
my $fileAsString = read_file("w3-total-cache-config-ticketfly.com.php");
open(FILE, ">outfiletest") || die "Ouch, dead! Cannae open file\n";

my @outfileText;

sub extractMemcacheSection {
    print "BOOP!\n";
    my $txt = shift;
    if ($txt =~ m/(.*)(memcached.servers\' => array\(.*?\))(.*)/sm) {
        print "MATCJED! $2\n";
        print FILE $1;
        push(@outfileText,$1);
        my $cleanMemcacheArray = removeHost($2);
        print "CLEAN\n$cleanMemcacheArray\n";
        print FILE $cleanMemcacheArray;
        push(@outfileText,$cleanMemcacheArray);
        if (length($3) > 0) {
            extractMemcacheSection($3);
        }
    } else {
        push(@outfileText,$txt);
        print "FINISHED - NO MORE MATCH LAST SECTION \n $txt";
    }
}

sub removeHost {
    my @txtarray = split('\n', shift);
    my @hosts;
    my @returnText;
    foreach my $line(@txtarray) {
        if ($line =~ /^memcach.*/) { $line = $line . "\n"; push (@returnText,$line); }
        if ($line =~ /(10.10.\d{1,3}.\d{1,3}:11211)/) {
            push(@hosts,$1);
        }
    }
    my @newHosts = grep { !/$hostToRemove/ } @hosts;
    for my $i (0 .. $#newHosts) {
            my $line = "               $i => \'$newHosts[$i]\',\n";
            push (@returnText,$line);
    }
    push(@returnText,"        )\n");
    my $cleanedArray = join "", @returnText;
}

extractMemcacheSection($fileAsString);
#print "@outfileText";
print FILE @outfileText;
close(FILE);
