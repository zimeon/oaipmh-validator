# CPAN upload notes

A reminder for @zimeon...

  * Check all branches up to date etc.
  * Check tests `prove -lv`
  * Check version number `grep VERSION lib/HTTP/OAIPMH/Validator.pm`
  * `perl Makefile.PL`
  * `make test`
  * `make dist` will create file `HTTP-OAIPMH-Validator-V.VV.tar.gz` (where `V.VV` is the version number)
  * Login to PAUSE at <https://pause.perl.org/pause/authenquery>, select **Upload a file to CPAN** and upload the tar.gz file, which should then show under **Show my files**. After some time additional `.meta` and `.readme` files will appear

After some time, the updated module should show up on

  * [cpan.org](http://search.cpan.org/dist/HTTP-OAIPMH-Validator)
  * [metacpan.org](https://metacpan.org/pod/HTTP::OAIPMH::Validator) 
