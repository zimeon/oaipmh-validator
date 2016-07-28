# Tests for HTTP::OAIPMH::Validator::test_get_record
use strict;

use Test::More tests => 6;
use Test::Exception;
use HTTP::Response;
use HTTP::Headers;
use HTTP::OAIPMH::Validator;

my $v;
$v = HTTP::OAIPMH::Validator->new;
$v->base_url( 'http://example.org/oai' );
ok( $v, "created Validator object" );

# Set up dummy response handler to short-circuit actual request, must
# return a valid HTTP::Response object
my @RESPONSES = (); 
$v->ua->add_handler( request_send => sub { return shift(@RESPONSES); } );

$v->log->num_fail(0);
$v->test_get_record('id1', undef);
is( $v->log->num_fail, 1, 'missing format check');

$v->log->num_fail(0);
$v->test_get_record(undef, 'format1');
is( $v->log->num_fail, 1, 'missing id check');

@RESPONSES = ( HTTP::Response->new(500, '') );
$v->log->num_fail(0);
throws_ok { $v->test_get_record('id1', 'oai_dc') }
    qr/ABORT: Can't complete datestamp check for GetRecord/,
    '500, check abort';

# Test with exception
my $msg = <<"XML1";
<?xml version="1.0" encoding="UTF-8"?>
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
         http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
  <responseDate>2001-06-01T19:20:30Z</responseDate> 
  <request verb="GetRecord">http://example.org/oai</request>
  <error code="idDoesNotExist">ooops</error>
</OAI-PMH>
XML1
@RESPONSES = ( HTTP::Response->new(200, 'OK', HTTP::Headers->new(), $msg) );
$v->log->num_fail(0);
throws_ok { $v->test_get_record('oai:arXiv.org:cs/0112017', 'oai_dc'); }
    qr/ABORT: Unexpected OAI exception response/,
    'idDoesNotExist error abort';

# Test with example from spec
# https://www.openarchives.org/OAI/openarchivesprotocol.html#GetRecord
my $msg = <<"XML2";
<?xml version="1.0" encoding="UTF-8"?> 
<OAI-PMH xmlns="http://www.openarchives.org/OAI/2.0/" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/
         http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd">
  <responseDate>2002-02-08T08:55:46Z</responseDate>
  <request verb="GetRecord" identifier="oai:arXiv.org:cs/0112017"
           metadataPrefix="oai_dc">http://arXiv.org/oai2</request>
  <GetRecord>
   <record> 
    <header>
      <identifier>oai:arXiv.org:cs/0112017</identifier> 
      <datestamp>2001-12-14</datestamp>
      <setSpec>cs</setSpec> 
      <setSpec>math</setSpec>
    </header>
    <metadata>
      <oai_dc:dc 
         xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
         xmlns:dc="http://purl.org/dc/elements/1.1/" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
         xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ 
         http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
        <dc:title>Using Structural Metadata to Localize Experience of 
                  Digital Content</dc:title> 
        <dc:creator>Dushay, Naomi</dc:creator>
        <dc:subject>Digital Libraries</dc:subject> 
        <dc:description>With the increasing technical sophistication of 
            both information consumers and providers, there is 
            increasing demand for more meaningful experiences of digital 
            information. We present a framework that separates digital 
            object experience, or rendering, from digital object storage 
            and manipulation, so the rendering can be tailored to 
            particular communities of users.
        </dc:description> 
        <dc:description>Comment: 23 pages including 2 appendices, 
            8 figures</dc:description> 
        <dc:date>2001-12-14</dc:date>
      </oai_dc:dc>
    </metadata>
  </record>
 </GetRecord>
</OAI-PMH>
XML2
@RESPONSES = ( HTTP::Response->new(200, 'OK', HTTP::Headers->new(), $msg) );
$v->log->num_fail(0);
$v->test_get_record('oai:arXiv.org:cs/0112017', 'oai_dc');
is( $v->log->num_fail, 0, 'good example from spec');

