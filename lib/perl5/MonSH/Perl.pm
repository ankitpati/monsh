package MonSH::Perl;

our $VERSION = '1.0.0';

# Modules to be Imported
use strict;
use warnings;

use utf8;
use utf8::all;
use warnings FATAL => 'utf8';

use autodie;
use Carp;

no indirect qw(fatal);

use English qw(-no_match_vars);

use feature qw(:5.16);
# End of Modules to be Imported

use Import::Into;

sub import {
    my $class = shift;

    my %target;
    @target{qw( package filename line )} = caller;

    strict->import::into (\%target);
    warnings->import::into (\%target);

    utf8->import::into (\%target);
    utf8::all->import::into (\%target);
    warnings->import::into (\%target, FATAL => 'utf8');

    autodie->import::into (\%target);
    Carp->import::into (\%target);

    indirect->unimport::out_of (\%target, 'fatal');

    English->import::into (\%target, '-no_match_vars');

    feature->import::into (\%target, ':5.16');

    return;
}

sub unimport {
    croak 'Unimporting MonSH::Perl is not allowed!';
    return;
}

1;
__END__

=encoding utf8

=head1 NAME

C<MonSH::Perl> - The minimum standard Perl for MonSH Tests

=head1 VERSION

1.0.0

=head1 SYNOPSIS

    use MonSH::Perl;

=head1 DESCRIPTION

    use MonSH::Perl;

is equivalent to

    use strict;
    use warnings;

    use utf8;
    use utf8::all;
    use warnings FATAL => 'utf8';

    use autodie;
    use Carp;

    no indirect qw(fatal);

    use English qw(-no_match_vars);

    use feature qw(:5.16);

Aside from the features implicitly added by setting the Perl minimum version
to 5.16, this module does not enable any additional features to Perl, only
restrictions.

Note that there is no C<no MonSH::Perl> -- you’re stuck with it!

=head1 DEVELOPMENT

Each C<import> added to this module must be updated at 3 places:

=over

=item 1.

Top B<Modules to be Imported> Section

=item 2.

C<import> Method

=item 3.

C<DESCRIPTION> in the POD

=back

Do not C<use> or C<require> any C<MonSH::*> modules here, because
all of them, except this one, of course, mandatorily
C<use MonSH::Perl>, and we don’t want circular dependencies.

=cut
