#!/usr/bin/perl

package InsideOutBase;

use strict;
use warnings;

use Class::Tie::InsideOut;

our @ISA = qw( Class::Tie::InsideOut );


BEGIN {
  no strict 'refs';
  foreach my $field (qw( foo bar )) {
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
}

package InsideOutInherited;

our @ISA = qw( InsideOutBase );


BEGIN {
  no strict 'refs';
  foreach my $field (qw( bo baz )) {
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
}

package main;

use strict;
use warnings;

use Test::More tests => 6;

my $obj = InsideOutInherited->new();
ok($obj->isa("InsideOutInherited"));
ok($obj->isa("InsideOutBase"));
ok($obj->isa("Class::Tie::InsideOut"));

{
  # local $TODO = "inheritance does not work";
  my $exp = 0;
  eval {
    $obj->set_foo(12);
    $exp = $obj->get_foo;
    # 
  };
  ok( !$@, "no error from inherited methods" );
  ok( $exp == 12, "tested inherited method" );
}

$obj->set_baz(99);
ok( $obj->get_baz == 99, "tested added method" );
