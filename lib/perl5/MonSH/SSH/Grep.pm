package MonSH::SSH::Grep;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;

use MonSH::SSH qw(sshcmd);

use String::ShellQuote qw(shell_quote);

use parent qw(Exporter);
our @EXPORT_OK = qw(sshgrep);

sub sshgrep {
    my ($hosts, $pattern, @files);
    $hosts = shift if 'ARRAY' eq ref $_[0];
    ($pattern, @files) = @_;

    croak 'Usage: sshgrep $pattern, $file1, $file2, ...'
        if not @files or
           grep { not defined $_ or ref $_ or $_ eq '' } $pattern, @files;

    return sshcmd $hosts // (), "grep -E -- " . shell_quote $pattern, @files;
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::SSH::Grep> - Grep logs over SSH

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::SSH::Grep qw(sshgrep);
    say {sshgrep qw(ERROR /var/log/httpd/error.log)}->{host1}{stdout};

=head1 DESCRIPTION

Greps for the given pattern in the given files.

It is safe to use extended regexps of the C<grep -E> flavour, because that is
what we actually use to implement this.

One or more hosts from the ones mentioned in the config file may be chosen per
command by passing them in an C<ARRAY>ref as the first argument.

=head1 TODO

Gracefully upgrade to C<pt>, C<rg>, and the ultimate searcher of them all:
C<ack>, if they are installed.

=cut
