#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

require Tie::InsideOut;
require Class::Tie::InsideOut;

ok( $Tie::InsideOut::VERSION == $Class::Tie::InsideOut::VERSION,
    "versions match" );
