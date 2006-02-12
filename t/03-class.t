#!/usr/bin/perl

package InsideOut;

use Class::Tie::InsideOut;

our @ISA = qw( Class::Tie::InsideOut );

our %GoodKey;

sub set_val {
  my $self = shift;
  my $key  = shift;
  $self->{$key} = shift;
}

sub get_val {
  my $self = shift;
  my $key  = shift;
  return $self->{$key};
}

package main;

use Test::More tests => 4;

my $obj = InsideOut->new();
ok($obj->isa("InsideOut"));
ok($obj->isa("Class::Tie::InsideOut"));

$obj->set_val('GoodKey',1);
ok($obj->get_val('GoodKey') == 1, "set/get");

undef $@;
eval { $obj->set_val('BadKey',1); };
ok( $@, "error on bad key" );
