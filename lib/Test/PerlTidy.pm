package Test::PerlTidy;

use strict;
use warnings;

use File::Finder;
use File::Slurp;
use Perl::Tidy;
use Text::Diff;

use Test::Builder;
require Exporter;
use vars qw( @ISA @EXPORT );
@ISA    = qw( Exporter );
@EXPORT = qw( run_tests );

our $VERSION;
$VERSION = '20070911';

my $Test = Test::Builder->new;
our $MUTE = 0;

sub run_tests {

    # Get the values and setup defaults if needed.
    my %args = @_;

    # Skip all tests if instructed to.
    $Test->skip_all("All tests skipped.") if $args{skip_all};

    # Get files to work with and set the plan.
    my @files = list_files('.');
    $Test->plan( tests => scalar @files );

    # Check each file in turn.
    foreach my $file (@files) {
        is_file_tidy($file);
    }
}

sub is_file_tidy {
    my $file_to_tidy = shift;
    my $test_name = shift || "'$file_to_tidy'";

    # $Test->diag("About to test '$file'\n");
    $Test->ok( _is_file_tidy($file_to_tidy), $test_name );
}

sub _is_file_tidy {
    my $file_to_tidy = shift;
    my $code_to_tidy = load_file($file_to_tidy);

    my $tidied_code = '';
    my $stderr      = '';
    my $logfile     = '';
    my $errorfile   = '';

    Perl::Tidy::perltidy(
        source      => \$code_to_tidy,
        destination => \$tidied_code,
        stderr      => \$stderr,
        logfile     => \$logfile,
        errorfile   => \$errorfile,
    );

    # If there were perltidy errors report them and return.
    if ($stderr) {
        $Test->diag("perltidy reported the following errors:\n") unless $MUTE;
        $Test->diag($stderr) unless $MUTE;
        return 0;
    }

    # Compare the pre and post tidy code and return result.
    unless ( $code_to_tidy eq $tidied_code ) {
        unless ($MUTE) {
            $Test->diag("The file '$file_to_tidy' is not tidy\n");
            $Test->diag(
                diff( \$code_to_tidy, \$tidied_code, { STYLE => 'Table' } ) );
        }

        return 0;
    }
    else {
        return 1;
    }
}

sub list_files {
    my $path = shift;
    die "You need to specify which directory to scan"
      unless defined $path && length $path;

    my @files = ();

    # Die if we got a bad dir.
    die "The directory '$path' does not exist" unless -d $path;

    # Find files using File::Finder.
    @files = File::Finder->type('f')->in($path);

    return

      # Sort the output so that it is repeatable
      sort

      # Filter out only the files that end in .pl, .pm, .PL or .t
      grep { m/\.(pl|pm|PL|t)$/; }

      # Filter out blib
      grep { !m|^\./blib/|; } @files;
}

sub load_file {
    my $filename = shift;

    # If the file is not regular then return undef.
    return undef unless -f $filename;

    # Slurp the file.
    my $content = read_file($filename);
    return $content;
}

=head1 NAME
 
Test::PerlTidy - check that all your files are tidy.
 
=head1 SYNOPSIS
 
    # In a file like 't/perltidy.t'
    use Test::PerlTidy;
    run_tests();

=head1 DESCRIPTION
 
This rather unflattering comment was made in a piece by Ken Arnold:

    "Perl is a vast swamp of lexical and syntactic swill and nobody
    knows how to format even their own code well, but it's the only
    major language I can think of (with the possible exception of the
    recent, yet very Java-like C#) that doesn't have at least one
    style that's good enough."
              http://www.artima.com/weblogs/viewpost.jsp?thread=74230

Hmmm... He is sort of right in a way. Then again the piece he wrote
was related to Python which is somewhat strict about formatting
itself.

Fear not though - now you too can have your very own formatting
gestapo in the form of Test::PerlTidy! Simply add a test file as
suggested above and any file ending in .pl, .pm, .t or .PL will cause
a test fail unless it is exactly as perltidy would like it to be.

=head1 REASONS TO DO THIS

If the style is mandated in tests then it will be adhered to.

If perltidy decides what is a good style then there should be no
quibbling.

If the style never changes then cvs diffs stop catching changes that
are not really there.

Readability might even improve.

=head1 HINTS

If you want to change the default style then muck around with
'.perltidyrc';

To quickly make a file work then try 'perltidy -b the_messy_file.pl'.

=head1 SEE ALSO

L<Perl::Tidy>

=head1 AUTHOR
 
evdb@ecclestoad.co.uk Edmund von der Burg

=head1 SUGGESTIONS

Please let me know if you have any comments or suggestions.

L<http://ecclestoad.co.uk/>
 
=head1 LICENSE
 
This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.
 
=cut

1;
