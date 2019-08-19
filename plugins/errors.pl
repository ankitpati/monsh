#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;

use MonSH::Config qw(config);
use MonSH::SSH::Grep qw(sshgrep);

my %outputs = sshgrep config ('error_string'), values %{ config 'log_files' };

my (@warning, @critical);

while (my ($host, $out) = each %outputs) {
    my $stdout = $out->{stdout};
    next if $stdout eq '';
    push @warning, $host and next if config ('errors_critical_threshold')
                                        > split /\n/, $stdout;
    push @critical, $host;
}

local $LIST_SEPARATOR = ', ';

if (@critical) {
    say "CRITICAL - Logs indicate too many errors on Hosts (@critical)!";
    exit 2;
}
elsif (@warning) {
    say "WARNING - Logs indicate fewer than 10 errors on Hosts (@warning).";
    exit 1;
}
else {
    say 'OK - Logs indicate no error.';
    exit 0;
}
