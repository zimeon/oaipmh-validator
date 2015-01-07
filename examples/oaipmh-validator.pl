#!/usr/bin/env perl

=head1 NAME

oaipmh-validator.pl -- OAI-PMH Data Provider Validator

=cut

use strict;

use HTTP::OAIPMH::Validator;
use Try::Tiny;
use Getopt::Std;
use Pod::Usage;

my %opt;
(getopts('sh',\%opt)&&!$opt{h}) || pod2usage();

foreach my $base_url (@ARGV) {
    print "\n# RUNNING VALIDATION FOR $base_url\n";
    my $val = HTTP::OAIPMH::Validator->new( base_url=>$base_url, allow_https=>$opt{s} );
    $val->log->fh(\*STDOUT); $|=1;
    try {
	$val->run_complete_validation;
    } catch {
	warn "\noops, validation didn't run to completion: $_\n";
    };
    print "\n## Validation status of data provider ".$val->base_url." is ".$val->status."\n";
}
