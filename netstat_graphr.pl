#!/usr/bin/perl -w
use strict;
use Net::Statsd;

$Net::Statsd::HOST = '10.10.4.34';

my $hostname = `hostname --short`; ## LINUX
chomp $hostname;
#print "HOST:: $hostname \n";

my @ports = qw(80 88);
 
while(1) {
  foreach my $p(@ports) {
        my $stats = `netstat  -antu |grep ':$p '|grep -v tcp6 | grep -v LISTEN | awk '{print \$6}' |sort | uniq -c`;
        my @stats = split('\n',$stats);
        foreach my $s (@stats) {
                $s =~ s/^\s+//;
                my ($count,$state) = $s =~ /(\d+) (.*)/;
                $state = lc($state);
                my $k = $hostname . "_" . $p . "_" . $state;
                print "$k - $count\n";
                Net::Statsd::gauge("$k", $count);
        } 
  }
  sleep 10;
}
