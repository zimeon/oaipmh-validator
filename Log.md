# NAME

HTTP::OAIPMH::Log - Log of validation results

# SYNOPSIS

Validation logging for [HTTP::OAIPMH::Validator](https://metacpan.org/pod/HTTP::OAIPMH::Validator). Stores log of information
as an array of entries in $self->log, where each entry is itself an array
where the first element is the type (indicated by a string) and then additional
information.

Also supports output of a text summary during operation is $self->fh is 
set to a filehandle for output.

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

### num\_total()

Return the total number of pass and fail events recorded. Note 
that this doesn't include warnings.
