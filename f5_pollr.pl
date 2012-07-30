#!/usr/bin/perl -w
use strict;
# THIS SCRIPT MAKES USE OF THE PROVIDED F5 MIBS 
# INSTALL THEM IN /usr/share/mibs/netsnmp/
# PVA = Packet Velocity ASIC

my $walkr = "snmpwalk -v2c -c public 10.10.5.230 '";
my $step = 5; # five seconds - used for measuring delta between two points

####### OIDs #########
my @mem_use = qw[sysStatMemoryUsed sysHostMemoryUsed]; 
my @active_connections = qw [ sysStatClientCurConns sysStatServerCurConns 
    sysStatPvaClientCurConns sysStatPvaServerCurConns sysClientsslStatCurConns sysServersslStatCurConns ];
my @new_connections = 
    qw [ sysTcpStatAccepts sysStatServerTotConns sysStatClientTotConns sysStatServerTotConns
         sysStatPvaClientTotConns sysStatPvaServerTotConns sysClientsslStatTotNativeConns 
         sysClientsslStatTotCompatConns sysServersslStatTotNativeConns sysServersslStatTotCompatConns
         sysTcpStatAccepts sysTcpStatConnects ];
my @throughput_rates =
    qw [ sysStatClientBytesIn sysStatClientBytesOut sysStatServerBytesIn sysStatServerBytesOut
         sysStatClientBytesIn sysStatClientBytesOut sysStatServerBytesIn sysStatServerBytesOut 
         sysHttpStatPrecompressBytes ];
my @http_requests = qw [ sysStatHttpRequests ];

#########################
# MEM USAGE - STATIC SINGLE MEASUREMENT
my %mem_usage_results = &getSNMP(\@mem_use);
#foreach my $k(keys %mem_usage_results) {
#        print "$k = $mem_usage_results{$k}\n";
#}

#########################
# DYNAMIC MEASUREMENTS - NEED DELTA TO CALCULATE 
my %active_connections_results_1 = &getSNMP(\@active_connections);
my %new_connections_results_1 = &getSNMP(\@new_connections);
my %throughput_rates_results_1 = &getSNMP(\@throughput_rates);
my %http_requests_results_1 = &getSNMP(\@http_requests);
sleep $step;
my %active_connections_results_2 = &getSNMP(\@active_connections);
my %new_connections_results_2 = &getSNMP(\@new_connections);
my %throughput_rates_results_2 = &getSNMP(\@throughput_rates);
my %http_requests_results_2 = &getSNMP(\@http_requests);

foreach my $k(keys %active_connections_results_2) {
     print "$k = $active_connections_results_2{$k}\n";
}

# BUILD GMETRIC RETURN RESULTS #####
######
# CONNECTIONS
print "NUM1 - $new_connections_results_2{'sysTcpStatAccepts'},$new_connections_results_1{'sysTcpStatAccepts'} \n";
my $new_connections_client_accepts = 
    &calcDelta($new_connections_results_2{'sysTcpStatAccepts'},$new_connections_results_1{'sysTcpStatAccepts'});
print "NEW CONNECTIONS / CLIENT ACCEPTS : $new_connections_client_accepts/s\n";

sub getSNMP {
    my ($aref) = @_;
    my %results;
    foreach(@$aref) {
#        print "$_\n";
        my $cmd = "$walkr" . $_ . "'";
#        print "CMD: $cmd\n";
        chomp(my $result = `$cmd`);
        my @results = split(/ /,$result);
        $results{ $_ } = $results[3];
    }
    return %results;
}


# FOLLOWING METRICS ALL TAKE A DELTA AND REQUIRE A CALCULATION
#my %active_connections_results1;
#my %active_connections_results2;
#
#
#
#
sub calcDelta {
    my $value2 = shift;
    my $value1 = shift;
    my $val = ($value2 - $value1) / $step;
    return($val);
}
#
