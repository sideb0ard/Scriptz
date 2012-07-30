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
my $start_time = time;

# DYNAMIC MEASUREMENTS - NEED DELTA TO CALCULATE  - STEP ONE
my %new_connections_results_1 = &getSNMP(\@new_connections);
my %throughput_rates_results_1 = &getSNMP(\@throughput_rates);
my %http_requests_results_1 = &getSNMP(\@http_requests);

my $finish_time = time;
my $runtime = $finish_time - $start_time;
print "Runtime $runtime\n";
sleep ($step - $runtime);

# DYNAMIC - COLLECT ONCE ABOVE AND
my %new_connections_results_2 = &getSNMP(\@new_connections);
my %throughput_rates_results_2 = &getSNMP(\@throughput_rates);
my %http_requests_results_2 = &getSNMP(\@http_requests);

# STATIC - ONLY COLLECT ONCE
my %mem_usage_results = &getSNMP(\@mem_use);
my %active_connections_results = &getSNMP(\@active_connections);

foreach my $k(keys %mem_usage_results) {
        # TODO _ CALL GMETRIC
        print "$k = $mem_usage_results{$k}\n";
}

foreach my $k(keys %active_connections_results) {
     print "$k = $active_connections_results{$k}\n";
    # TODO _ CALL GMETRIC
}

# BUILD GMETRIC RETURN RESULTS #####
######
# CONNECTIONS
my $new_connections_client_accepts = 
    &calcDelta($new_connections_results_2{'sysTcpStatAccepts'},$new_connections_results_1{'sysTcpStatAccepts'});
print "NEW CONNECTIONS / CLIENT ACCEPTS : $new_connections_client_accepts/s\n";
my $new_connections_server_connects = 
    &calcDelta($new_connections_results_2{'sysStatServerTotConns'},$new_connections_results_1{'sysStatServerTotConns'});
print "NEW CONNECTIONS / SERVER CONNECTS : $new_connections_server_connects/s\n";
my $total_new_connections_client_connects = 
    &calcDelta($new_connections_results_2{'sysStatClientTotConns'},$new_connections_results_1{'sysStatClientTotConns'});
print "TOTAL NEW CONNECTIONS / CLIENT ACCEPTS : $total_new_connections_client_connects/s\n";
my $total_new_connections_server_connects = 
    &calcDelta($new_connections_results_2{'sysStatServerTotConns'},$new_connections_results_1{'sysStatServerTotConns'});
print "TOTAL NEW CONNECTIONS / SERVER CONNECTS : $total_new_connections_server_connects/s\n";

# THROUGHPUT RATES
#foreach my $k(keys %throughput_rates_results_2) {
#     print "$k = $throughput_rates_results_2{$k}\n";
#}
my $throughput_client_bits = 
    ((($throughput_rates_results_2{'sysStatClientBytesIn'} - $throughput_rates_results_1{'sysStatClientBytesIn'}) +
    ($throughput_rates_results_2{'sysStatClientBytesOut'} - $throughput_rates_results_1{'sysStatClientBytesOut'})) * 8) / $step;
print "THROUGHPUT CLIENT BITS: $throughput_client_bits/s\n";
# TODO _ CALL GMETRIC
my $throughput_server_bits = 
    ((($throughput_rates_results_2{'sysStatServerBytesIn'} - $throughput_rates_results_1{'sysStatServerBytesIn'}) +
    ($throughput_rates_results_2{'sysStatServerBytesOut'} - $throughput_rates_results_1{'sysStatServerBytesOut'})) * 8) / $step;
print "THROUGHPUT SERVER BITS: $throughput_server_bits/s\n";
# TODO _ CALL GMETRIC
my $throughput_compression = 
    (($throughput_rates_results_2{'sysHttpStatPrecompressBytes'} - $throughput_rates_results_1{'sysHttpStatPrecompressBytes'}) * 8) / $step;
print "THROUGHPUT COMPRESSION: $throughput_compression/s\n";
# TODO _ CALL GMETRIC

# HTTP REQUESTS
#foreach my $k(keys %http_requests_results_2) {
#    print "$k = $http_requests_results_2{$k}\n";
#    }
my $http_requests = 
    ($http_requests_results_2{'sysStatHttpRequests'} - $http_requests_results_1{'sysStatHttpRequests'}) / $step;
print "HTTP REQUESTS: $http_requests/s\n";
# TODO _ CALL GMETRIC



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
