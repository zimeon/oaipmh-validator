# Simple tests for HTTP::OAIPMH::Validator
use strict;

use Test::More tests => 3;
use HTTP::OAIPMH::Validator;

my $v = HTTP::OAIPMH::Validator->new;
ok( $v, "created Validator object" );


##### FUNCTIONS

is( HTTP::OAIPMH::Validator::one_year_before('1999-01-01'), '1998-01-01', 'one_year_before 1999-01-01' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-02-03'), '1999-02-03', 'one_year_before 2000-02-03' );
