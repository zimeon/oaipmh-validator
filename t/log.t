# Tests for HTTP::OAIPMH::Log
use strict;

use Test::More tests => 1;
use HTTP::OAIPMH::Log;

my $log = HTTP::OAIPMH::Log->new;
ok( $log, "created Log object" );

