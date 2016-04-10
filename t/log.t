# Tests for HTTP::OAIPMH::Log
use strict;

use Test::More tests => 58;
use HTTP::OAIPMH::Log;
use JSON qw(decode_json);

my $log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );

# add loggers
is( $log->fh, undef, "empty fh" );
is( $log->fh(\*STDERR), \*STDERR, "stderr fh" );
is( $log->fh(undef), undef, "empty fh" );
is( $log->fh(\*STDOUT), \*STDOUT, "stderr fh, json" );
is( scalar(@{$log->filehandles}), 2, "2 loggers");

# logging
$log = $log->new;
ok( $log, "created new Log object" );
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
ok( $log->warn('be-careful','very-careful'), "warn 2" );
is( $log->num_warn, 2, "2 warn" );
is( $log->total, 2, '2 pass+fail (warn not included in total)' );

is( $log->num_pass, 0, "no pass" );
ok( $log->pass('gud'), "pass" );
is( $log->num_pass, 1, "1 pass" );
is( $log->total, 3, '3 pass+fail' );

# _add method and on-the-fly output in markdown
my $str;
my $fh;
$log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );
$str=''; open( $fh, '>', \$str);
is( $log->fh($fh), $fh, "connected out to str" );
ok( $log->_add("ONE","SOME"), "_add ONE SOME" );
is( $str, "ONE:     SOME\n", "one line written" );

$log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );
$str=''; open($fh, '>', \$str); 
is( $log->fh($fh), $fh, "connected out to str" );
ok( $log->_add("TITLE","bingo"), "_add TITLE BINGO" );
is( $str, "\n### bingo\n\n", "bingo line written" );

$log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );
$str=''; open($fh, '>', \$str); 
is( $log->fh($fh), $fh, "connected out to str" );
ok( $log->_add("WARN","short","long"), "_add WARN short long" );
is( $str, "WARN:    short\n", "WARN line written without long" );
ok( $log->_add("FAIL","short","very very very long"), "_add FAIL short long" );
is( $str, "WARN:    short\nFAIL:    short\n", "FAIL line written without long" );

$log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );
$str=''; open($fh, '>', \$str); 
is( $log->fh($fh), $fh, "connected out to str" );
ok( $log->_add("NOTE","one","two","three"), "_add NOTE one two three" );
is( $str, "NOTE:    one two three\n", "NOTE line written with all elements" );

# _add method and on-the-fly output in json
my $str;
my $fh;
$log = HTTP::OAIPMH::Log->new;
ok( $log, "created new Log object" );
$str=''; open( $fh, '>', \$str);
is( $log->fh($fh,'json'), $fh, "connected out to str, type json" );
ok( $log->_add("ONE","SOME"), "_add ONE SOME" );
my $j = decode_json($str);
is( $j->{'num'}, 1, 'num==1' );
is( $j->{'type'}, 'ONE', 'type==ONE' );
is( $j->{'msg'}, 'SOME', 'msg==SOME' );
ok( $j->{'timestamp'}, 'timestamp is True' );
