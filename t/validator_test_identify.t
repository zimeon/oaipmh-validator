# Tests for HTTP::OAIPMH::Validator::test_identify
use strict;

use Test::More tests => 4;
use Test::Exception;
use HTTP::Response;
use HTTP::Headers;
use HTTP::OAIPMH::Validator;
use Try::Tiny;

my $v;
$v = HTTP::OAIPMH::Validator->new;
$v->base_url( 'http://example.org/oai' );
ok( $v, "created Validator object" );

# Set up dummy response handler to short-circuit actual request, must
# return a valid HTTP::Response object
my @RESPONSES = ();
$v->ua->add_handler( request_send => sub { return shift(@RESPONSES); } );

@RESPONSES = ( HTTP::Response->new(301, '')); 
$v->log->num_fail(0);
try {
    $v->test_identify();
};
is( $v->log->num_fail, 2, 'error and abort');
ok( $v->log->log->[2][1]=~/HTTP code 301/, 'mentions 301');
ok( $v->log->log->[3][1]=~/ABORT/, 'abort');
