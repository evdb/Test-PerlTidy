#!perl -T

use strict;
use warnings;

use Test::PerlTidy;

run_tests( path => '.', exclude => ['blib/'], debug => 0 );
