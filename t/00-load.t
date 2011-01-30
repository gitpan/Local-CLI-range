#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Local::CLI::range' );
}

diag( "Testing Local::CLI::range $Local::CLI::range::VERSION, Perl $], $^X" );
