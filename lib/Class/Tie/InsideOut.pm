package Class::Tie::InsideOut;

require Class::ISA;
require Tie::InsideOut;

our $VERSION = '0.03';

our @ISA = qw( );

sub new {
  my $class = shift || __PACKAGE__;
  my $self = { };
  tie %$self, 'Tie::InsideOut',
    grep $_->isa('Class::Tie::InsideOut'), Class::ISA::self_and_super_path($class);
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

Fields are accessed as hash keys, so in traditional Perl objects can be
easily converted into inside-out objects.

=begin readme

More information can be found in the module documentation.

=end readme

=for readme stop

To use, inherit our class from L<Class::Tie::InsideOut> and then specify
the legal keys for your object to use as hashes within the classes namespace:

  package MyClass;

  use Class::Tie::InsideOut;

  our @ISA = qw( Class::Tie::InsideOut );

  our (%Field1, %Field2, %Field3 ); # Fields used by MyClass

Note that your keys must be specified as C<our> variables so that they are accessible
from outside of the class, and not as C<my> variables!

Fields are accessed as hash keys from the object reference:

  sub method {
    my $self = shift;
    if (@_) {
      $self->{Field1} = shift;
    }
    else {
      return $self->{Field1};
    }
  }

Converting a Perl module which uses "traditional" objects into one which
uses inside-out objects can be a matter of adding L<Class::Tie::InsideOut>
to the C<@ISA> list and adding the field names as global hashes.

When a class is inherited from from a L<Class::Tie::InsideOut> class, then
it too must be an inside out class and have the fields defined as global
hashes.  This will affect inherited classes downstream.

The namespaces of super classes which themselves are L<Class::Tie::InsideOut>
are passed to L<Tie::InsideOut>, so that inherited methods will not cause
an error.

This version does little checking of the key names, beyond that there is a
global hash variable with that name.  It might be a hash intended as a
field, or it might be one intended for something else. (You could hide
them by specifying them as C<my> variables, though.)

There are no checks against using the name of a tied L<Tie::InsideOut> or
L<Class::Tie::InsideOut> global hash variable as a key for itself, which
has unpredicable (and possibly dangerous) results.

=for readme continue

=begin readme

=head1 REVISION HISTORY

A brief list of changes since the previous release:

=for readme include file="Changes" start="0.03" stop="0.02" type="text"

For a detailed history see the F<Changes> file included in this distribution.

=end readme

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

