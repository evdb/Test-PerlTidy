
use strict;
use warnings;

use Test::More;
use Perl::Tidy;

BEGIN {
    my $PT_VERSION = '20071205';
    if ( $Perl::Tidy::VERSION ne $PT_VERSION ) {
        plan skip_all =>
          "Tidy for Perl::Tidy $PT_VERSION - you have $Perl::Tidy::VERSION";
    }
}

use Test::PerlTidy;
run_tests();
