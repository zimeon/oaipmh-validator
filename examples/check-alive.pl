#!/usr/bin/env perl
use strict;
use lib qw(lib);
use HTTP::OAIPMH::Validator;
use Try::Tiny;
foreach my $base_url (@ARGV) {
    my $val = HTTP::OAIPMH::Validator->new( base_url=>$base_url, http_timeout=>10 );
    try {
	if ($val->test_identify) {
	    print $base_url." OK\n";
	} else {
	    print $base_url." BAD \n";
        }
    } catch {
	print $base_url." $_\n";
    };
}
