# Simple tests for HTTP::OAIPMH::Validator
use strict;

use Test::More tests => 1;
use HTTP::OAIPMH::Validator;

my $v = HTTP::OAIPMH::Validator->new;
ok( $v, "created Validator object" );

