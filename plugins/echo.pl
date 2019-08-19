#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;

use MonSH::Config qw(config);
use MonSH::SSH qw(sshcmd);

my $hello_msg = config 'hello_msg';

my %outputs = sshcmd "echo $hello_msg";

my (@warning, @critical);

while (my ($host, $out) = each %outputs) {
    my $stdout = $out->{stdout};
    next if $stdout eq "$hello_msg\n";
    push @warning, $host and next if length $stdout;
    push @critical, $host;
}

local $LIST_SEPARATOR = ', ';

if (@critical) {
    say "CRITICAL - Hosts (@critical) do not respond over SSH!";
    exit 2;
}
elsif (@warning) {
    say "WARNING - Hosts (@warning) respond incorrectly over SSH!";
    exit 1;
}
else {
    say 'OK - Hosts respond correctly over SSH';
    exit 0;
}
