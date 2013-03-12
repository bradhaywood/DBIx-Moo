#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'DBIx::Moo' ) || print "Bail out!\n";
}

diag( "Testing DBIx::Moo $DBIx::Moo::VERSION, Perl $], $^X" );
