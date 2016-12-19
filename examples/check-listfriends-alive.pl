#!/usr/bin/env perl
#
# Check whether base URLs supplied in a file
# ListFriends format as given in response to
# http://www.openarchives.org/Register/ListFriends 
# are alive. Output to stdout.
#
use strict;
use lib qw(lib);
use HTTP::OAIPMH::Validator;
use Try::Tiny;
use XML::Simple;
use Data::Dumper;

my $lfin = XMLin('ListFriends.xml', ForceContent => 1);
$| = 1;
my $n = 0;
print "# Started Identify checks at ".localtime()."\n";
foreach my $entry (@{$lfin->{'baseURL'}}) {
    $n++;
    my $base_url = $entry->{'content'};
    check_data_provider($base_url);
}
print "# Done at ".localtime().", $n base URLs checked.";


sub check_data_provider {
    my ($base_url) = @_;
    my $val = HTTP::OAIPMH::Validator->new(
        base_url=>$base_url,
        http_timeout=>10,
        allow_https=>1
    );
    #$val->log->fh(\*STDOUT);
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
            s/\s+$//;
            s/\n/ /g;
            print $base_url." $_\n";
        }
    };
}
