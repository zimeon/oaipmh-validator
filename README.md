# Perl OAI-PMH validator class

[![Build status](https://travis-ci.org/zimeon/oaipmh-validator.svg?branch=master)](https://travis-ci.org/zimeon/oaipmh-validator)
[![Test coverage](https://coveralls.io/repos/zimeon/oaipmh-validator/badge.png?branch=master)](https://coveralls.io/r/zimeon/oaipmh-validator?branch=master)

*Work in progress...*

Tidy and refactor of code used for the OAI-PMH validation services
at <http://www.openarchives.org/data/registerasprovider.html>. Not yet
complete and not yet used for that service...

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
