# Tests for HTTP::OAIPMH::Log
use strict;

use Test::More tests => 29;
use HTTP::OAIPMH::Log;

my $log = HTTP::OAIPMH::Log->new;
ok( $log, "created Log object" );

# accessors
is( $log->fh, undef, "empty fh" );
is( $log->fh(\*STDERR), \*STDERR, "stderr fh" );
is( $log->fh(undef), undef, "empty fh" );

is( $log->total, 0, 'zero total' );
is( scalar(@{$log->log}), 0, "no entries" );

ok( $log->start('beginning'), "begin" );
is( scalar(@{$log->log}), 1, "1 entry" );
is( $log->log->[0][0], 'TITLE', "title entry" );
is( $log->log->[0][1], 'beginning', "content is beginning" );

ok( $log->request('http://example.com'), "request" );
ok( $log->request('http://example.com','GET'), "get request");
ok( $log->request('http://example.com','POST'), "post request");
ok( $log->request('http://example.com','POST','post=data'), "post request");
is( scalar(@{$log->log}), 5, "5 entries" );

ok( $log->note('inote'), "note" );

is( $log->total, 0, 'no pass+fail' );
ok( $log->fail('yu-so-bad'), "fail" );
is( $log->total, 1, '1 pass+fail' );
ok( $log->fail('very-bad','and here is why...'), "fail" );
is( $log->total, 2, '2 pass+fail' );

is( $log->num_warn, 0, "no warn" );
ok( $log->warn('be-careful'), "warn" );
is( $log->num_warn, 1, "1 warn" );
is( $log->total, 2, '2 pass+fail' );

is( $log->num_pass, 0, "no pass" );
ok( $log->pass('gud'), "pass" );
is( $log->num_pass, 1, "1 pass" );
is( $log->total, 3, '3 pass+fail' );

