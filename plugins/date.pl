#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;

use MonSH::Config qw(config);
use MonSH::SSH::Date qw(sshdate);

my %outputs = sshdate;

my @warning;

my $time = time;
my $time_skew_threshold = config 'time_skew_threshold';

while (my ($host, $out) = each %outputs) {
    push @warning, $host if $time_skew_threshold < abs $time - $out->{stdout};
}

unless (@warning) {
    say 'OK - Hosts are within Time Skew Threshold';
    exit 0;
}
else {
    local $LIST_SEPARATOR = ', ';
    say "WARNING - Hosts (@warning) are off by more than " .
        "$time_skew_threshold seconds!";
    exit 1;
}
