package Tie::InsideOut;

use 5.006001;
use strict;
use warnings;

our $VERSION = '0.01';

my $Counter;
my %NameSpaces;
my %Keys;

sub TIEHASH {
  my $class = shift || __PACKAGE__;
  my $id    = ++$Counter;

  {
    my $caller = (shift || (caller)[0]) . "::";
    no strict 'refs';
    $NameSpaces{$id} = *{$caller};
    unless (exists $NameSpaces{$id}) {
      die "bad namespace: $caller";
    }
  }
  $Keys{$id} = { };

  my $self  = \$id;
  bless $self, $class;
}

sub UNTIE {
  my $self = shift;
  my $id   = $$self;

  $self->CLEAR;

  delete $Keys{$id};
  delete $NameSpaces{$id};
}

sub DESTROY {
  goto &UNTIE;
}

sub CLEAR {
  my $self = shift;
  my $id   = $$self;

  foreach my $key (keys %{$Keys{$id}}) {
    delete $NameSpaces{$id}->{$key}->{$id};
  }
  $Keys{$id} = { };
}

sub FETCH {
  my $self = shift;
  my $key  = shift;

  my $id   = $$self;
  unless (exists $NameSpaces{$id}->{$key}) {
    die "Symbol \%".$key." does not exist in callers namespace";
  }
  $NameSpaces{$id}->{$key}->{$id};
}

sub EXISTS {
  my $self = shift;
  my $key  = shift;

  my $id   = $$self;
  unless (exists $NameSpaces{$id}->{$key}) {
    die "Symbol \%".$key." does not exist in callers namespace";
  }
  exists $NameSpaces{$id}->{$key}->{$id};
}

sub FIRSTKEY {
  my $self = shift;
  my $id   = $$self;
  return each %{$Keys{$id}};
}

sub NEXTKEY {
  my $self = shift;
  my $id   = $$self;
  return each %{$Keys{$id}};
}

sub DELETE {
  my $self = shift;
  my $key  = shift;

  my $id   = $$self;
  unless (exists $NameSpaces{$id}->{$key}) {
    die "Symbol \%".$key." does not exist in callers namespace";
  }
  delete $Keys{$id}->{$key};
  delete $NameSpaces{$id}->{$key}->{$id};
}

sub STORE {
  my $self = shift;
  my $key  = shift;
  my $val  = shift;

  my $id   = $$self;
  unless (exists $NameSpaces{$id}->{$key}) {
    die "Symbol \%".$key." does not exist in callers namespace";
  }
  $Keys{$id}->{$key} = 1; # Track keys defined
  $NameSpaces{$id}->{$key}->{$id} = $val;
}

BEGIN {
  *new = \&TIEHASH;
}

1;
__END__


=head1 NAME

Tie::InsideOut - Tie hashes to variables in caller's namespace

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

  use Tie::InsideOut;

  our %GoodKey;

  tie %hash, 'Tie::InsideOut';

  ...

  $hash{GoodKey} = 1; # This will set a value in %GoodKey

  $hash{BadKey}  = 1; # This will cause an error if %BadKey does not exist

=head1 DESCRIPTION

This package ties hash so that the keys are the names of variables in the caller's
namespace.  If the variable does not exist, then attempts to access it will die.

An alternative namespace can be specified, if needed:

  tie %hash, 'Tie::InsideOut', 'Other::Class';

This gives a convenient way to restrict valid hash keys, as well as provide a
transparent implementation of inside-out objects, as with L<Class::Tie::InsideOut>.

This package also tracks which keys were set, and attempts to delete keys when an
object is destroyed so as to conserve resources. (Whether the overhead in tracking
used keys outweighs the savings is yet to be determined.)

=head1 SEE ALSO

L<perltie>

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
