#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;

use MonSH::SSH qw(sshcmd);

my %outputs = sshcmd 'test';

my @critical;

while (my ($host, $out) = each %outputs) {
    my ($stdout, $stderr, $exit) = @$out{qw(stdout stderr exit)};
    push @critical, $host if $stdout ne '' or $stderr ne '' or $exit != 1;
}

unless (@critical) {
    say 'OK - Hosts are running a Bourne-compatible shell';
    exit 0;
}
else {
    local $LIST_SEPARATOR = ', ';
    say "CRITICAL - Hosts (@critical) are not running a Bourne-compatible " .
        'shell!';
    exit 2;
}
