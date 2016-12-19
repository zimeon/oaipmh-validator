#!/usr/bin/env perl
#
# Check whether base URLs supplied on command line pass
# Identify checks, print results to stdout.
#
use strict;
use lib qw(lib);
use HTTP::OAIPMH::Validator;
use Try::Tiny;
foreach my $base_url (@ARGV) {
    my $val = HTTP::OAIPMH::Validator->new(
        base_url=>$base_url,
        http_timeout=>10
    );
    $val->log->fh(\*STDOUT);
    try {
        if ($val->test_identify) {
            print $base_url." OK\n";
        } else {
            print $base_url." FAILED\n";
        }
    } catch {
        my $regex = qr/received response code '(\d\d\d)'/;
        if (my $entry=$val->log->last_match($regex)) {
            my ($type, $msg) = @$entry;
            my ($code) = $msg =~ $regex;
            print $base_url. " HTTP_".($code || "NO_CODE")."\n";
        } else {
            print $base_url." $_\n";
        }
    };
}
