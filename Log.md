# NAME

HTTP::OAIPMH::Log - Log of validation results

# SYNOPSIS

Validation logging for [HTTP::OAIPMH::Validator](https://metacpan.org/pod/HTTP::OAIPMH::Validator). Stores log of information
as an array of entries in $obj->log, where each entry is itself an array
where the first element is the type (indicated by a string) and then additional
information.

Also supports output of a text summary (markdown) and/or JSON data
during operation if the $obj->filehandles array is set to include one
or more filehandle and types for output.

Example use:

    my $log = HTTP::OAIPMH::Log->new;
    $log->fh(\*STDOUT);
    $log->start("First test");
    ...
    $log->note("Got some data");
    ...
    if ($good) {
        $log->pass("It was good, excellent");
    } else {
        $log->fail("Should have been good but wasn't");
    }

## METHODS

### new(%args)

Create new HTTP::OAIPMH::Log and optionally set values for any of the
attributes. All attributes also have accessors provided via
[Class::Accessor::Fast](https://metacpan.org/pod/Class::Accessor::Fast):

    log - internal data structure for log messages (array of arrays)
    fh - set to a filehandle to write log messages as logging is done
    num_pass - number of pass messages
    num_fail - number of fail messages
    num_warn - number of warn messages

### fh($fh, $type)

Add a filehandle to the logger. If $type is set equal to 'json' then
JSON will be written, els if 'html then HTML will be written, otherwise
text is output in markdown format. The call is ignored unless $fh is True.

### num\_total()

Return the total number of pass and fail events recorded. Note
that this doesn't include warnings.

### start($title)

Start a test or section and record a title.

### request($url,$type,$content)

Add a note of the HTTP request used in this test. Must specify
the $url, may include the $type (GET|POST) and for POST
the $content.

### note($note)

Add note of extra information that doesn't impact validity.

### fail($msg,$longmsg)

Record a failure and increment the $obj->num\_fail count. Must have
a message $msg and may optionally include a longer explanation $longmsg.

### warn($msg,$longmsg)

Record a warning and increment the $obj->num\_warn count. Must have
a message $msg and may optionally include a longer explanation $longmsg.

### pass($msg,$longmsg)

Record a success and increment the $obj->num\_pass count. Must have
a message $msg explaining what has passed.
