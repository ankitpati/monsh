package MonSH::SSH::Date;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;

use MonSH::Config qw(config);
use MonSH::SSH qw(sshcmd);

use String::ShellQuote qw(shell_quote);

use parent qw(Exporter);
our @EXPORT_OK = qw(sshdate);

sub sshdate {
    my $hosts;
    $hosts = shift if 'ARRAY' eq ref $_[0];

    croak 'Usage: sshdate' if @_;

    my $date_format = config 'date_format';
    return sshcmd $hosts // (), sprintf 'date +%s', shell_quote $date_format;
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::SSH::Date> - Get date/time over SSH

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::SSH::Date qw(sshdate);
    say {sshdate}->{host1}{stdout};

=head1 DESCRIPTION

Returns date/time information.

As of now, the UNIX timestamp is returned, as seconds since epoch.

This is configurable through the config key, C<date_format>. Unless there is a
very good reason, always add new items to the end of the config value so
existing code (hopefully) does not break.

One or more hosts from the ones mentioned in the config file may be chosen per
command by passing them in an C<ARRAY>ref as the first argument.

=cut
