package MonSH::Config;

our $VERSION = '1.0.0';

use File::Basename qw(dirname);
use lib dirname(__FILE__) . '/../' x (-1 + split /::/, __PACKAGE__);

use MonSH::Perl;

use JSON qw(decode_json);

use parent qw(Exporter);
our @EXPORT_OK = qw(config);

use constant {
    CFGDIR => dirname(__FILE__) . '/../' x (1 + split /::/, __PACKAGE__)
                                . 'etc/',
    CFGFILE => 'config.json',
};

my %config;

sub config {
    my $cfg = shift;
    croak 'Config name must be a single string!'
        if @_ or ref $cfg or not $cfg;

    unless (%config) {
        my $cfgjson;

        {
            local $INPUT_RECORD_SEPARATOR;
            open my $cfgfile, '<', CFGDIR . CFGFILE;
            $cfgjson = <$cfgfile>;
            close $cfgfile;
        }

        %config = %{ decode_json $cfgjson };
        $config{cfgdir} = CFGDIR;
    }

    return $config{$cfg} if exists $config{$cfg};

    croak "“$cfg” is not a valid config name!";
    return;
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::Config> - Handles Config for MonSH Tests

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::Config qw(config);
    say config 'hello_msg';

=head1 DESCRIPTION

Reads a JSON config file, usually from C<etc/config.json>, and makes it
available for querying through the exported C<config> subroutine.

All data structures possible in JSON are allowed as config values, and we will
simply return a Perl equivalent--usually a C<HASH>ref or an C<ARRAY>ref.

It is not possible to alter the config values at runtime.

=cut
