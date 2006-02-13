#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;

use_ok('Tie::InsideOut');

my %hash;

undef $@;
eval { tie %hash, 'Tie::InsideOut', 'Some::Bad::Namespace'; };
ok($@, "died on bad namespace");


