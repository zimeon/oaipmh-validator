#!/usr/bin/env perl
#
# Tweak to validator example to quietly run validation but then to report
# a summary (including a sumary of any failures), after validation.
#
use strict;

use lib qw(lib);

use HTTP::OAIPMH::Validator;
use Try::Tiny;

foreach my $base_url (@ARGV) {
    print "\n# RUNNING VALIDATION FOR $base_url\n";
    my $val = HTTP::OAIPMH::Validator->new(base_url=>$base_url);
    try {
        $val->run_complete_validation;
    };
    print $val->failures();
    print $val->summary();
}
