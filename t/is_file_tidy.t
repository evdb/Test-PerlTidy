use strict;
use warnings;

use Test::More tests => 2;

use Test::PerlTidy;

{
    local ${Test::PerlTidy::MUTE} = 1;
    ok Test::PerlTidy::_is_file_tidy('t/tidy_file'),   't/tidy_file';
    ok !Test::PerlTidy::_is_file_tidy('t/messy_file'), 't/messy_file';
}
