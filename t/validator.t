# Simple tests for HTTP::OAIPMH::Validator
use strict;

use Test::More tests => 27;
use Try::Tiny;
use HTTP::OAIPMH::Validator;

my $v;
$v = HTTP::OAIPMH::Validator->new;
ok( $v, "created Validator object" );

#setup_user_agent
is( ref($v->setup_user_agent()), 'LWP::UserAgent', 'setup_user_agent' );

#abort (should die)
my $caught='abort did not die';
try {
    $v->abort('bwaaaa!');
} catch {
    $caught=$_;
};
ok( $caught=~m/^ABORT: bwaaaa! /, 'abort dies' );

#run_complete_validation

#summary
ok( $v = HTTP::OAIPMH::Validator->new, 'new validator object' );
ok( $v->summary=~/## Summary - \*success\*/, 'summary has title' );
ok( $v->summary=~/  \* Total tests passed 0/ );
ok( $v->summary=~/  \* Total warnings 0/ );
ok( $v->summary=~/  \* Total error count: 0/ );
ok( $v->summary=~/  \* Validation status: unknown/, 'summary has status unknown' );

#test_identify
#test_list_sets
#test_list_identifiers
#test_list_metadata_formats
#test_get_record
#test_list_records
#test_resumption_tokens
#test_expected_errors
#test_expected_v2_errors
#test_post_requests
#test_post_request
#check_response_date
#check_schema_name
#check_protocol_version

#is_verb_response

#error_elements_include
#check_error_response
#get_earliest_datestamp

#parse_granularity

#get_datestamp_granularity

#is_no_records_match

#get_resumption_token

#is_error_response

#get_admin_email

#bad_admin_email

#make_request_and_validate

#make_request

#parse_response

##### FUNCTIONS

#html_escape
is( HTTP::OAIPMH::Validator::html_escape(), undef, 'html_escape()' );
is( HTTP::OAIPMH::Validator::html_escape(''), '', 'html_escape("")' );
is( HTTP::OAIPMH::Validator::html_escape('abcdefghi'), 'abcdefghi', 'html_escape(abcdefghi)' );
is( HTTP::OAIPMH::Validator::html_escape('<&>"'), '&lt;&amp;&gt;&quot;', 'html_escape(<&>")' );

#one_year_before
is( HTTP::OAIPMH::Validator::one_year_before('1999-01-01'), '1998-01-01', 'one_year_before 1999-01-01' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-02-03'), '1999-02-03', 'one_year_before 2000-02-03' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-01-01'), '1999-01-01' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-01-01'), '1999-01-01' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-99-99'), '1999-99-99' );
is( HTTP::OAIPMH::Validator::one_year_before('2000-99-99T01:02:03.22'), '1999-99-99T01:02:03.22' );

#url_encode
is( HTTP::OAIPMH::Validator::url_encode(), undef, "url_encode()" );
is( HTTP::OAIPMH::Validator::url_encode(''), '', "url_encode('')" );
is( HTTP::OAIPMH::Validator::url_encode('abcdef'), 'abcdef', "url_encode('abcdef')" );
is( HTTP::OAIPMH::Validator::url_encode('a b%'), 'a+b%25', "url_encode('a b%')" );

#is_https_uri
is( HTTP::OAIPMH::Validator::is_https_uri(), '', "is_https_uri()" );
ok( !HTTP::OAIPMH::Validator::is_https_uri('http://example.com/'), "is_https_uri()" );
ok( HTTP::OAIPMH::Validator::is_https_uri('https://example.com/'), "is_https_uri()" );
ok( !HTTP::OAIPMH::Validator::is_https_uri('ftp://example.com/https://'), "is_https_uri()" );
