#!/usr/bin/perl -w
use strict;
use File::Slurp;

my $hostToRemove = "10.10.5.54";
my $fileAsString = read_file("w3-total-cache-config-ticketfly.com.php");
open(FILE, ">outfiletest") || die "Ouch, dead! Cannae open file\n";

sub extractMemcacheSection {
    my $txt = shift;
    $txt =~ m/(.*)(memcached.servers\' => array\(.*?\))(.*)/sm;
    print "$2\n";
    removeHost($2);
    if (length($3) > 0) {
        extractMemcacheSection($2);
    }
}

sub removeHost {
    my @txtarray = split('\n', shift);
    my @hosts;
    foreach my $line(@txtarray) {
        if ($line =~ /(10.10.\d{1,3}.\d{1,3}:11211)/) {
            push(@hosts,$1);
        }
    }
    print "HOSTS:@hosts\n";
    my @newHosts = grep { !/$hostToRemove/ } @hosts;
    print "NEWHOSTS:@newHosts\n";
}

extractMemcacheSection($fileAsString);
close(FILE);
