package MonSH::SSH;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;

use MonSH::Config qw(config);

use Net::SSH::Perl;

use parent qw(Exporter);
our @EXPORT_OK = qw(sshcmd);

my %ssh;

sub sshcmd {
    my ($hosts, $cmd);
    $hosts = shift if 'ARRAY' eq ref $_[0];
    $cmd = shift;

    croak 'Command must be a single string!'
        if @_ or ref $cmd or not $cmd;

    unless (%ssh) {
        my $cfgdir = config 'cfgdir';
        my %params = (
            user_config => "$cfgdir/" . config('ssh_config'),
            identity_files =>
                [ map { "$cfgdir/$_" } @{ config 'ssh_priv_keys' } ],
            user_known_hosts => "$cfgdir/" . config('ssh_known_hosts'),
        );

        foreach my $ssh_host (@{ $hosts // config 'ssh_hosts' }) {
            $ssh{$ssh_host} = Net::SSH::Perl->new ($ssh_host, %params);
            $ssh{$ssh_host}->login;
        }
    }

    my %outputs;

    while (my ($host, $ssh) = each %ssh) {
        my ($stdout, $stderr, $exit) = $ssh->cmd ($cmd);
        @{ $outputs{$host} }{qw(stdout stderr exit)}
            = ($stdout // '', $stderr // '', $exit);
    }

    return %outputs;
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::SSH> - Handles SSH for MonSH Tests

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::SSH qw(sshcmd);
    say {sshcmd 'echo hello'}->{host1}{stdout};

=head1 DESCRIPTION

Runs a command over SSH on the target host. There may be multiple target hosts
per test instance, but hostname and other details are not configurable, except
through config files.

One or more hosts from the ones mentioned in the config file may be chosen per
command by passing them in an C<ARRAY>ref as the first argument.

=cut
