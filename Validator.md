# NAME

HTTP::OAIPMH::Validator - OAI-PMH validator class

# SYNOPSIS

Validation suite for OAI-PMH data providers that checks for responses
in accord with OAI-PMH v2
[http://www.openarchives.org/OAI/2.0/openarchivesprotocol.htm](http://www.openarchives.org/OAI/2.0/openarchivesprotocol.htm).

Typical use:

    use HTTP::OAIPMH::Validator;
    use Try::Tiny;
    my $val = HTTP::OAIPMH::Validator->new( base_url=>'http://example.com/oai' );
    try {
        $val->run_complete_validation;
    } catch {
        warn "oops, validation didn't run to completion: $!\n";
    };
    print "Validation status of data provider ".$val->base_url." is ".$val->status."\n";

## METHODS

### new(%args)

Create new HTTP::OAIPMH::Validator object and initialize counters.

The following instance variables may be set via %args and have read-write
accessors (via [Class::Accessor::Fast](https://metacpan.org/pod/Class::Accessor::Fast)):

    base_url - base URL of the data provdier being validated
    run_id - UUID identifying the run (will be generated if none supplied)
    protocol_version - protocol version supported
    admin_email - admin email extracted from Identify response
    granularity - datestamp granularity (defaults to 'days', else 'seconds')
    uses_https - set true if the validator sees an https URL at any stage

    debug - set true to add extra debugging output
    log - logging object (usually L<HTTP::OAIPMH::Log>)
    parser - XML DOM parser instance

    identify_response - string of identify response (used for registration record)
    earliest_datestamp - value extracted from earliestDatestamp in Identify response
    namespace_id - if the oai-identifier is used then this records the namespace identifier extracted
    set_names - array of all the set names reported in listSets

    example_record_id - example id used for tests that require a specific identifier
    example_set_spec - example setSpec ("&set=name") used for tests that require a set
    example_metadata_prefix - example metadataPrefix which defaults to 'oai_dc'

### setup\_run\_id()

Set a UUID for the run\_id.

### setup\_user\_agent()

Setup [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) for the validator.

### abort($msg)

Special purpose "die" routine because tests cannot continue. Logs
failure and then dies.

### run\_complete\_validation($skip\_test\_identify)

Run all tests for a complete validation and return true is the data provider passes,
false otherwise. All actions are logged and may be accessed to provide a report
(including warnings that do not indicate failure) after the run.

Arguments:
  $skip\_identify - set true to skip the text\_identify() step

### summary()

Return summary statistics for the validation in Markdown (designed to agree
with conversion to HTML by [Text::Markdown](https://metacpan.org/pod/Text::Markdown)).

## METHODS TESTING SPECIFIC OAI-PMH VERBS

### test\_identify()

Check response to an Identify request. Returns false if tests cannot
continue, true otherwise.

Side effects based on values extracted:

    - $self->admin_email set to email extracted from adminEmail element
    - $self->granularity set to 'days' or 'seconds'

### test\_list\_sets()

Check response to the ListSets verb.

Save the setSpecs for later use.

Note that the any set might be empty. So if test\_list\_identifiers doesn't
get a match, we need to try the second set identifier, and so on.
So keep a list of the setSpec elements.

### test\_list\_identifiers()

Check response to ListIdentifiers and record an example record id in
$self->example\_record\_id to be used in other tests.

If there are no identifiers, but the response is legal, stop the test with
errors=0, number of verbs checked is three.

As of version 2.0, a metadataPrefix argument is required.  Unfortunately
we need to call test\_list\_identifiers first in order to get an id for
GetRecord, so we simply use oai\_dc.

### test\_list\_metadata\_formats()

Vet the verb as usual, and then make sure that Dublin Core in included
In particular, we will check the metadata formats available for "record\_id",
obtained from checking the ListIdentifier verb.
Side effect: save available formats for later use (global "formats").
NOTE:if there are no formats, error will be picked up by getRecord

### test\_get\_record($record\_id, $format)

Try to get record $record\_id in $format.

If either $record\_id or $format are undef then we have an error
right off the bat. Else make the request and return the
datestamp of the record.

### test\_list\_records($datestamp,$metadata\_prefix)

Test the response for the ListRecords verb.  In addition, if there is
no Dublin Core available for this repository, this is an error.
(And the error has already been counted in test\_get\_record)
We can still test the verb, however, with one of the available
formats found by testGetMetadataFormats.  Since the output of
ListRecords is likely to be large, use the datestamp of the one
record we did retrieve to limit the output.

### test\_resumption\_tokens()

Request an unlimited ListRecords. If there is a resumption token, see
if it works.  It is an error if resumption is there but doesn't work.
Empty resumption tokens are OK -- this ends the list.

CGI takes care of URL-encoding the resumption token.

## METHODS CHECKING ERRORS AND EXCEPTIONS

### test\_expected\_errors($record\_id)

Each one of these requests should get a 400 response in OAI-PHM v1.1,
or a 200 response in 2.0, along with a Reason\_Phrase.  Bump error\_count
if this does not hold. Return the number of errorneous responses.

$record\_id is a valid record identifier to be used in tests that require
one.

### test\_expected\_v2\_errors($earliest\_datestamp,$metadata\_prefix)

There are some additional exception tests for OAI-PMH version 2.0.

## METHODS TO TEST USE OF HTTP POST

### test\_post\_requests()

Test responses to POST requests. Do both the simplest possible -- the Identify
verb -- and a GetRecord request which uses two additional parameters.

## METHODS CHECKING ELEMENTS WITHIN VERB AND ERROR RESPONSES

### check\_response\_date($req, $doc)

Check responseDate for being in UTC format
(should perhaps also check that it is at least the current day?)

### check\_schema\_name($req, $doc)

Given the response to one of the OAI verbs, make sure that it it
going to be validated against the "official" OAI schema, and not
one that the repository made up for itself.  If the response can't
be parsed, or if there is no OAI-PMH element, or if the schema is
incorrect, print an error message and bump the error\_count.

Return true if the schema name and date check out, else return undef

### check\_protocol\_version

Extract the protocol version being used from the Identify response, check that it is
valid and then abort unless 2.0.

## is\_verb\_response($reponse,$verb)

Return true if $response is a response for the specified $verb.

FIXME -- need better checks!

### error\_elements\_include($error\_elements,$error\_codes)

Determine whether the list of error elements ($error\_elements) includes at least
one of the desired codes. Return string with first matching error code, else
return false/nothing.

Does a sanity check on $error\_list to check that it is set and has length>0
before trying to match, so cose calling it can simply do a
getElementsByTagName or similar before caling.

### check\_error\_response($response)

Given the response to an HTTP request, make sure it is not an
OAI-PMH error message.  The $response is a success.  If it is an
OAI error message, return 2; if the response cannot be parsed, return
\-1; otherwise return undef (it must be a real Identify response).

FIXME -- need better checks!

FIXME -- need to merge thic functionality in with is\_error\_response

### get\_earliest\_datestamp()

A new exception check for Version 2.0 raises noRecordsMatch errorcode
if the set of records returned by ListRecords is empty.  This requires
that we know the earliest date in the repository.  Also check that the
earliest date matches the specified granularity.

Called only for version 2.0 or greater.

Since the Identify response has already been validated, we know
there is exactly one earliestDatestamp element in the current document.
Extract this value, check it, and if it looks good then set
$self->earliest\_datestamp and return false.

If there is an error then return string explaining that.

### parse\_granularity($granularity\_element)

Parse contents of the granularity element of the Identify response. Returns either
'days', 'seconds' or nothing on failure. Sets $self->granularity if valid, otherwise
does not change setting.

As of v2.0 the granularity element is mandatory, see:
http://www.openarchives.org/OAI/openarchivesprotocol.html#Identify

### get\_datestamp\_granularity($datestamp)

Parse the datestamp supplied and return 'days' if it is valid with granularity
of days, 'seconds' if it is valid for seconds granularity, and nothing if it is not
valid.

\# FIXME - should add more validation

### is\_no\_records\_match

Returns true if the current document contains and error code element with the code "noRecordsMatch"

\### FIXME - should be merged into an extended is\_error\_response

### get\_resumption\_token()

See if there is a resumptionToken with this response, return
value if present, empty if not or if there is some other error.

### is\_error\_response($details)

Look at the parsed response in $self->doc to see if it is an error response,
parse data and return true if it is.

Returns true (a printable string containing the error messages) if response was a valid
OAI\_PMH error response, codes in %$details if a hash reference is passed in.

### get\_admin\_email()

Extract admin email from a parsed Identify response in $self->doc).
Also note that the email target may have been set via form option

Returns the pair of ($email,$error) where $email is the combined
set of email addresses (comma separated). $error will be undef
or a string with error message to users.

### bad\_admin\_email($admin\_email)

Check for some stupid email addresses to avoid so much bounced email.
Returns a string (True) if bad, else nothing.

## METHODS FOR MAKING REQUESTS AND PARSING RESPONSES

### make\_request\_and\_validate($verb, $req)

Given the base URL that we are validating, the Verb that we are checking
and the complete query to be sent to the OAI server, get the response to
the verb.  Validation has already been done, so we need only do some
special checks here.  Return the response to the OAI verb,
or undef if the OAI server failed to respond to that verb.

Side effects: errors may be printed and error\_count bumped.
If the verb involved is "Identify" then set the version number and the
email address, assuming that some response has been obtained.

Simple well-formedness is checked by this routine. An undef exit means
that any calling code should fail the test but need not report 'no response'.

If the response is true then $self->doc contains a parsed XML
document.

This is the usual way we make requests with integrated parsing and error
checking. This method is built around calls to [make\_request](https://metacpan.org/pod/make_request) and
[parse\_response](https://metacpan.org/pod/parse_response).

### make\_request($url,$post\_data)

Routine to GET or POST a request, handle 503's, and return the response

Second parameter, $post\_data, must be hasfref to POST data to indicate that
the request should be an HTTP POST request instead of a GET.

### parse\_response($request\_url,$response,$xml\_reason)

Attempt to parse the HTTP response $response, examining both the response code
and then attempting to parse the content as XML.

If $xml\_reason is specified then ...FIXME

Returns true on success and sets $self->doc with the parsed XML document.
If unsuccessful, log an error message, bump the error count, and
return false.

## UTILITY FUNCTIONS

### html\_escape($str)

Escapes characters which have special meanings in HTML

### one\_year\_before($date)

Assumes properly formatted date, decrements year by one
via string manipulation and returns date.

### url\_encode($str)

Escape/encode any characters that aren't in the small safe set for URLs

### is\_https\_uri($uri)

Return true if the URI is an https URI, false otherwise.

### sanitize($str)

Return a sanitized version of $str that doesn't contain odd
characters and it not over 80 chars long. Will have the
string '(sanitized)' appended if changed.

# SUPPORT

Please report any bugs of questions about validation via the
OAI-PMH discussion list at  [https://groups.google.com/d/forum/oai-pmh](https://groups.google.com/d/forum/oai-pmh).
Be sure to make it clear that you are talking about the
HTTP::OAIPMH::Validator module.

# AUTHORS

Simeon Warner, Donna Bergmark

# HISTORY

This module is based on an OAI-PMH validator first written by Donna Bergmark
(Cornell University) in 2001-01 for the OAI-PMH validation and registration
service ([http://www.openarchives.org/data/registerasprovider.html](http://www.openarchives.org/data/registerasprovider.html)).
Simeon Warner (Cornell University) took over the validator and operation of
the registration service in 2004-01, and then did a significant tidy/rework
of the code. That code ran the validation and registration service with
few changes through 2015-01. Some of the early work on the OAI-PMH validation
service was supported through NSF award number 0127308.

Code was abstracted into this module 2015-01 by Simeon Warner and will
be used for the OAI-PMH validation and registration service.

# COPYRIGHT

Copyright 2001..2016 by Simeon Warner, Donna Bergmark.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.
