#!/usr/bin/env perl

=head1 NAME

oaipmh-validator.pl -- OAI-PMH Data Provider Validator

=head1 SYNOPSIS

oaipmh-validator.pl [-s] [-h] [[baseURL]]

Will run validator on baseURL (and optionally additional baseURLs) with
progress 

  -s   allow HTTPS base URL (not part of the OAI-PMH specification)
  -v   verbose debugging output
  -h   this help

=cut

use strict;

use lib qw(lib);

use HTTP::OAIPMH::Validator;
use Try::Tiny;
use Getopt::Std;
use Pod::Usage;

my %opt;
(getopts('dsh',\%opt)&&!$opt{h}) || pod2usage();

foreach my $base_url (@ARGV) {
    print "\n# RUNNING VALIDATION FOR $base_url\n";
    my $val = HTTP::OAIPMH::Validator->new( base_url=>$base_url, allow_https=>$opt{s}, debug=>$opt{d} );
    $val->log->fh(\*STDOUT); $|=1;
    try {
	$val->run_complete_validation;
    } catch {
	warn "\noops, validation didn't run to completion: $_\n";
    };
    print "\n## Validation status of data provider ".$val->base_url." is ".$val->status."\n";
}
