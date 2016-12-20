# Perl OAI-PMH validator class

[![Build status](https://travis-ci.org/zimeon/oaipmh-validator.svg?branch=master)](https://travis-ci.org/zimeon/oaipmh-validator)
[![Coverage Status](https://coveralls.io/repos/github/zimeon/oaipmh-validator/badge.svg?branch=master)](https://coveralls.io/github/zimeon/oaipmh-validator?branch=master)

Tidy and refactor of code used for the OAI-PMH validation service
at <http://www.openarchives.org/pmh/register_data_provider>.

## Test validator

A complete command-line validator based on this module is provided in
the examples directory, use -h for help:

```
> examples/oaipmh-validator.pl -h
```

## Documentation extracted from Perl POD

  * [HTTP::OAIPMH::Validator](Validator.md)
  * [HTTP::OAIPMH::Log](Log.md)

## Installation and CPAN

This module is available from CPAN, see 
<https://metacpan.org/pod/HTTP::OAIPMH::Validator> or 
<http://search.cpan.org/~simeon/HTTP-OAIPMH-Validator/>,
and may be downloaded in the usual way:

```
> cpan HTTP::OAIPMH::Validator
```

Alternatively source may be downloaded from github or CPAN and
either used without installing (e.g. as test validator is above),
or installed as described in <README.cpan.md>.
