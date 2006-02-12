package Class::Tie::InsideOut;

require Tie::InsideOut;

our $VERSION = '0.01';

sub new {
  my $class = shift;
  my $self = { };
  tie %$self, 'Tie::InsideOut', $class;
  bless $self, $class;
}


1;

__END__

=head1 NAME

Class::Tie::InsideOut - Inside-out objects on the cheap using tied hashes

=begin readme

=head1 REQUIREMENTS

Perl 5.6.1. No non-core modules are used.

=head1 INSTALLATION

Installation can be done using the traditional Makefile.PL or the newer
Build.PL methods.

Using Makefile.PL:

  perl Makefile.PL
  make test
  make install

(On Windows platforms you should use C<nmake> instead.)

Using Build.PL (if you have Module::Build installed):

  perl Build.PL
  perl Build test
  perl Build install

=end readme

=head1 SYNOPSIS

  package MyClass;

  use Class::Tie::InsideOut;

  our @ISA = qw( Class::Tie::InsideOut );

  our %GoodKey;

  sub bad_method {
    my $self = shift;
    return $self->{BadKey}; # this won't work
  }

  sub good_method {
    my $self = shift;
    return $self->{GoodKey}; # %GoodKey is defined
  }

=head1 DESCRIPTION

This module is a proof-of-concept on of implementing inside-out objects
using tied hashes.  It makes use of the L<Tie::InsideOut> package to tie
hash keys to hashes in the calling package's namespace.

Fields are accessed as hash keys, so in theory traditional Perl objects
can be easily converted into inside-out objects.

=begin readme

More information can be found in the module documentation.

=end readme

=for readme stop

To use, inherit our class from L<Class::Tie::InsideOut> and then specify
the legal keys for your object to use as hashes within the classes namespace.

Note that your keys must be specified as C<our> variables so that they are accessible
from outside of the class, and not as C<my> variables.

=for readme continue

=head1 SEE ALSO

This module is a wrapper for L<Tie::InsideOut>.

There are various other inside-out object packages on CPAN. Among them:

  Class::InsideOut
  Object::InsideOut

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head2 Suggestions and Bug Reporting

Feedback is always welcome.  Please use the CPAN Request Tracker at
L<http://rt.cpan.org> to submit bug reports.

=head1 LICENSE

Copyright (c) 2006 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

