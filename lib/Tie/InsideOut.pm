package Tie::InsideOut;

use 5.006001;
use strict;
use warnings;

use Carp qw( croak );

our $VERSION = '0.04';

my $Counter;
my %NameSpaces;
my %Keys;

sub TIEHASH {
  my $class = shift || __PACKAGE__;
  my $id    = ++$Counter;

  {
    my $caller = shift || (caller)[0];
    no strict 'refs';
    $NameSpaces{$id} = $caller;
  }
  $Keys{$id} = { };

  my $self  = \$id;
  bless $self, $class;
}

sub UNTIE {
  my $self = shift;
  my $id   = $self->_get_id;

  $self->CLEAR;

  delete $Keys{$id};
  delete $NameSpaces{$id};
}

sub DESTROY {
  goto &UNTIE;
}

sub CLEAR {
  my $self = shift;
  my $id   = $self->_get_id;

  foreach my $key (keys %{$Keys{$id}}) {
    foreach my $namespace (keys %{$Keys{$id}->{$key}}) {
      delete $Keys{$id}->{$key}->{$namespace}->{$id};
    }
  }
  $Keys{$id} = { };
}

sub FETCH {
  my $self = shift;
  my $key  = shift;

  my ($id, $hash_ref) = $self->_validate_key($key);
  $hash_ref->{$id};
}

sub EXISTS {
  my $self = shift;
  my $key  = shift;

  my ($id, $hash_ref) = $self->_validate_key($key);
  exists $hash_ref->{$id};
}

# Being able to iterate over the keys is useful, but limited. After version
# 0.03, encapsulation is enforced.

sub FIRSTKEY {
  my $self = shift;
  my $id   = $self->_get_id;
  return each %{$Keys{$id}};
}

sub NEXTKEY {
  my $self = shift;
  my $id   = $self->_get_id;
  return each %{$Keys{$id}};
}

sub DELETE {
  my $self = shift;
  my $key  = shift;

  my ($id, $hash_ref) = $self->_validate_key($key);
  delete $Keys{$id}->{$key};
  delete $hash_ref->{$id};
}

sub STORE {
  my $self = shift;
  my $key  = shift;
  my $val  = shift;

  my ($id, $hash_ref, $namespace)  = $self->_validate_key($key);
  $Keys{$id}->{$key}->{$namespace} = $hash_ref;
  $hash_ref->{$id}    = $val;
}

sub prefreeze {
  my $self = shift;
  my $id   = $self->_get_id;

  my $struc = { };
  my $refs  = [ $NameSpaces{$id}, $struc ];
  my $index = @$refs;

  foreach my $key (keys %{$Keys{$id}}) {
    foreach my $namespace (keys %{$Keys{$id}->{$key}}) {
      $struc->{$key}->{$namespace} = $index;
      $refs->[$index++] = $Keys{$id}->{$key}->{$namespace}->{$id};
    }
  }

  return $refs;
}

sub prethaw {
  my $self = shift;
  my $id   = $self->_get_id;

  my $refs = shift;

  croak("Namespaces do not match: ", $NameSpaces{$id}, " and ", $refs->[0]),
    unless ($NameSpaces{$id} eq $refs->[0]);

  $self->CLEAR;

  no strict 'refs';

  my $struc = $refs->[1];
  foreach my $key (keys %$struc) {
    foreach my $namespace (keys %{$struc->{$key}}) {
      my $index = $struc->{$key}->{$namespace};
      $namespace = "main" if ($namespace eq "");

      my $hash_ref = *{$namespace."::"};
      if ((exists $hash_ref->{$key}) &&  (ref *{$hash_ref->{$key}}{HASH})) {
	$Keys{$id}->{$key}->{$namespace} = $hash_ref->{$key};
	$hash_ref->{$key}->{$id} = $refs->[$index];
      }
      else {
	croak "Symbol \%".$key." not defined in namespace ".$namespace;
      }
    }
  }
}

sub _get_id {
  my $self = shift;
  return $$self;
}

sub _validate_key {
  my ($self, $key) = @_;
  my $id   = $self->_get_id;

  my $caller_namespace = (caller(2))[3];
  my $hash_ref;

  if ((defined $caller_namespace) && ($caller_namespace ne "(eval)")) {
    no strict 'refs';

    $caller_namespace =~ s/::(((?!::).)+)$//;
    $hash_ref = *{$caller_namespace."::"};
  }
  else {
    no strict 'refs';
    $caller_namespace = "";
    $hash_ref = *{$NameSpaces{$id}."::"}
     || croak "Cannot determine namespace of caller";
  }

  if ((exists $hash_ref->{$key}) &&  (ref *{$hash_ref->{$key}}{HASH})) {
    return ($id, $hash_ref->{$key}, $caller_namespace);
  }
  else {
    my $err_msg = "Symbol \%".$key." not defined";
    if ($caller_namespace ne "") {
      $err_msg .= " in namespace ".$caller_namespace;
    }
    croak $err_msg;
  }
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

Note that your keys must be specified as C<our> variables so that they are accessible
from outside of the class, and not as C<my> variables.

=head1 KNOWN ISSUES

This version does little checking of the key names, beyond that there is a
global hash variable with that name.  It might be a hash intended as a
field, or it might be one intended for something else. (You could hide
them by specifying them as C<my> variables, though.)

There are no checks against using the name of a tied L<Tie::InsideOut> or
L<Class::Tie::InsideOut> global hash variable as a key for itself, which
has unpredicable (and possibly dangerous) results.

Keys are only accessible from the namespace that the hash was tied. If you pass the
hash to a method in another object or a subroutine in another module, then it will
not be able to access the keys.  This is an intentional limitation for use with
L<Class::Tie::InsideOut>.

Because of this, tied hashes are not serializable or clonable outside of the box.

=head1 SEE ALSO

L<perltie>

L<Class::Tie::InsideOut>

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
