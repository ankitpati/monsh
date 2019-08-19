package MonSH::SSH::Stat;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;

use MonSH::Config qw(config);
use MonSH::SSH qw(sshcmd);

use String::ShellQuote qw(shell_quote);

use parent qw(Exporter);
our @EXPORT_OK = qw(sshstat);

sub sshstat {
    my ($hosts, @files);
    $hosts = shift if 'ARRAY' eq ref $_[0];
    @files = @_;

    croak 'Usage: sshstat $file1, $file2, ...'
        if not @files or
           grep { not defined $_ or ref $_ or $_ eq '' } @files;

    return sshcmd $hosts // (), sprintf 'stat -c %s -- %s',
                                        shell_quote (config 'stat_format'),
                                        shell_quote (@files);
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::SSH::Stat> - Stat files over SSH

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::SSH::Stat qw(sshstat);
    say {sshstat '/var/log/httpd/access.log'}->{host1}{stdout};

=head1 DESCRIPTION

Returns information about files and directories.

As of now, three pieces of information are returned: filename, file size, and
time of last modification as seconds since epoch.

This is configurable through the config key, C<stat_format>. Unless there is a
very good reason, always add new items to the end of the config value so
existing code (hopefully) does not break.

One or more hosts from the ones mentioned in the config file may be chosen per
command by passing them in an C<ARRAY>ref as the first argument.

=cut
