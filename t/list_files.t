use strict;
use warnings;

use Test::More tests => 1;

use Test::PerlTidy;

my @wanted_files = sort    #
  (
    './Makefile.PL',             #
    './lib/Test/PerlTidy.pm',    #
    './t/list_files.t',          #
    './t/perltidy.t',            #
    './t/is_file_tidy.t',        #
  );

my @found_files = Test::PerlTidy::list_files('.');

is_deeply( \@wanted_files, \@found_files );
