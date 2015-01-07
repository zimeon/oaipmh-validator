use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HTTP::OAIPMH::Validator',
    AUTHOR              => 'Simeon Warner <simeon@cpan.org>',
    ABSTRACT            => 'OAI-PMH Validator used for http://www.openarchives.org/pmh/validate',
    VERSION_FROM        => 'lib/HTTP/OAIPMH/Validator.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Class::Accessor::Fast' => 0.34,
	'Date::Manip' => 6.48,
        'HTTP::Request' => 6.00,
        'HTTP::Headers' => 6.05,
        'HTTP::Request::Common' => 6.04,
	'HTTP::Status' => 6.03,
        'LWP::UserAgent' => 6.06,
	'LWP::Protocol::https' => 6.06, #https support
        'URI::Escape' => 3.31,
        'XML::DOM' => 1.44,
    },
    BUILD_REQUIRES => {
	'Test::Pod' => 1.48,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HTTP-OAIPMH-Validator-*' },
);
