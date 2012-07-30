#!/usr/bin/perl -w
use strict;
# THIS SCRIPT MAKES USE OF THE PROVIDED F5 MIBS 
# INSTALL THEM IN /usr/share/mibs/netsnmp/

my $walkr = "snmpwalk -v2c -c public 10.10.5.230 '";

my @metrics = qw[sysStatMemoryUsed sysHostMemoryUsed sysStatClientCurConns sysStatServerCurConns 
                    sysStatPvaClientCurConns sysStatPvaServerCurConns sysClientsslStatCurConns sysServersslStatCurConns];

my @new_connection_stats = qw[sysTcpStatAccepts sysStatServerTotConns sysStatClientTotConns sysStatServerTotConns
                            sysStatPvaClientTotConns sysStatPvaServerTotConns sysClientsslStatTotNativeConns 
                            sysClientsslStatTotCompatConns sysServersslStatTotNativeConns sysServersslStatTotCompatConns
                            sysTcpStatAccepts sysTcpStatConnects];

my @throughput_rate_stats = qw[sysStatClientBytesIn sysStatServerBytesIn sysStatClientBytesIn sysStatClientBytesOut
                            sysStatServerBytesIn sysStatServerBytesOut sysHttpStatPrecompresssBytes];

my @http_request_stats = qw[sysStatHttpRequests];

my @ram_cache_use_stats = qw[sysHttpStatRamcacheHits sysHttpStatRamcacheHitBytes sysHttpStatRamcacheEvictions];
# my @cpu_use_stats = qw[];

while (1) {
my $http_reqs = calcDelta($http_request_stats[0],5);
}

sub calcDelta {
    my $oid = shift;
    my $interval = shift;
    my $sysStatHttpRequests1 = getResult($oid);
    sleep($interval);
    my $sysStatHttpRequests2 = getResult($oid);
    my $HttpRequests = ($sysStatHttpRequests2 - $sysStatHttpRequests1) / $interval;
    print "HTTP Requests = $HttpRequests\n";
}

sub getResult {
        my $metric = shift;
        my $cmd = "$walkr" . $metric . "'";
        chomp(my $result = `$cmd`);
        my @results = split(/ /,$result);
        return $results[3];
}

