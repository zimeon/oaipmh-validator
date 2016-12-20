#!/usr/bin/env perl

=head1 NAME

oaipmh-validator.pl -- OAI-PMH Data Provider Validator

=head1 SYNOPSIS

oaipmh-validator.pl [-s] [-h] [-i run_id] [-w] [[baseURL]]

Will run validator on and OAI-PMH data provider at baseURL. Will 
show progress as the validation and (optionally) write a log
of JSON snippets.

  -i run_id  use specified run_id (expected to be UUID, used as a
             file prefix, implies -w)
  -w         write responses to files in tmp
  -l logfile write log of JSON snippets
  -s         do not allow HTTPS base URL (not part of the OAI-PMH specification)
  -v         verbose debugging output
  -h         this help

=cut

use strict;

use lib qw(lib);

use HTTP::OAIPMH::Validator;
use Try::Tiny;
use Getopt::Std;
use Pod::Usage;

my %opt;
(getopts('i:wl:dsh',\%opt)&&!$opt{h}) || pod2usage();

if ($opt{i} and not $opt{i}=~m/^(\w[\w-]+\w)$/) {
   die "Error - bad value for -i.\n";
}
if ($opt{i} and scalar(@ARGV)>1) {
   die "Error - Can't use -i with mutliple baseURLs.\n";
}
$opt{w} ||= $opt{i};
if (scalar(@ARGV)!=1) {
    die "Error - Must specify one baseURL (-h for help).\n"
}
my $base_url = shift(@ARGV);

print "\n# RUNNING VALIDATION FOR $base_url\n";
my $val = HTTP::OAIPMH::Validator->new( base_url=>$base_url, 
                                        save_all_responses=>$opt{w},
                                        run_id=>$opt{i},
                                        allow_https=>not($opt{s}),
                                        debug=>$opt{d} );
$val->log->fh(\*STDOUT); $|=1;
if ($opt{l}) {
    open(my $lfh, '>', $opt{l}) || die "Ooops - failed to open log: $!";
    # make it autoflush
    my $ofh = select($lfh); $|=1; select($ofh);
    $val->log->fh($lfh,'json')
}
try {
    $val->run_complete_validation;
} catch {
    warn "\noops, validation didn't run to completion: $_\n";
};
print "\n## Validation status of data provider ".$val->base_url." is ".$val->status."\n";
