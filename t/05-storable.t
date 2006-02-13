#!/usr/bin/perl

package MyClass;

use base 'Class::Tie::InsideOut';

use strict;
use warnings;

sub clone {
  my $self = shift;
  my $serialized = freeze $self;
  return thaw($serialized);
}

BEGIN {
  no strict 'refs';
  foreach my $field (qw( foo bar bo baz )) {
    *{$field}       = { };
    *{"set_$field"} = sub {
      my $self = shift;
      $self->{$field} = shift;
    };
    *{"get_$field"} = sub {
      my $self = shift;
      $self->{$field};
    };
  }
  eval "use Storable qw( freeze thaw );";
}

package main;

use Test::More;

use strict;
use warnings;

eval "use Storable;";

plan skip_all => "Storable not installed" if ($@);

our %Settings = (
  foo => "abracadabra",
  bar => "ishkabibble",
  bo  => "saxarba",
  baz => 1999,
);

plan tests => 4 + (2 * (keys %Settings) );

my $a = MyClass->new();
ok($a->isa("MyClass"));
ok($a->isa("Class::Tie::InsideOut"));

foreach my $field (keys %Settings) {
  my $set_method = "set_$field";
  my $get_method = "get_$field";
  $a->$set_method($Settings{$field});
  ok( $a->$get_method eq $Settings{$field}, $field );
}

my $b = $a->clone;
ok($b->isa("MyClass"));
ok($b->isa("Class::Tie::InsideOut"));

foreach my $field (keys %Settings) {
  my $get_method = "get_$field";
  ok( $b->$get_method eq $Settings{$field}, $field );
}
