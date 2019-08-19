#!/usr/bin/env perl

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../lib/perl5';

use MonSH::Perl;

use MonSH::SSH qw(sshcmd);

my %outputs = sshcmd 'echo -n "$BASH_VERSION"';

my @warning;

while (my ($host, $out) = each %outputs) {
    push @warning, $host unless length $out->{stdout};
}

unless (@warning) {
    say 'OK - Hosts are running a Bash shell';
    exit 0;
}
else {
    local $LIST_SEPARATOR = ', ';
    say "WARNING - Hosts (@warning) are not running a Bash shell!";
    exit 1;
}
