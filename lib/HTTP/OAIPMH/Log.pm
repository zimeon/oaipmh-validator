package HTTP::OAIPMH::Log;

=head1 NAME

HTTP::OAIPMH::Log - Log of validation results

=head1 SYNOPSIS

Validation logging for L<HTTP::OAIPMH::Validator>. Stores log of information
as an array of entries in $obj->log, where each entry is itself an array
where the first element is the type (indicated by a string) and then additional
information.

Also supports output of a text summary during operation if $obj->fh is 
set to a filehandle for output.

Example use:

    my $log = HTTP::OAIPMH::Log->new;
    $log->fh(\*STDOUT);
    $log->start("First test");
    ...
    $log->note("Got some data");
    ...
    if ($good) {
        $log->pass("It was good, excellent");
    } else {
        $log->fail("Should have been good but wasn't");
    }

=cut

use strict;
use base qw(Class::Accessor::Fast);
HTTP::OAIPMH::Log->mk_accessors( qw(log fh num_pass num_fail num_warn) );

=head2 METHODS

=head3 new(%args)

Create new HTTP::OAIPMH::Log and optionally set values for any of the 
attributes. All attributes also have accessors provided via 
L<Class::Accessor::Fast>:

  log - internal data structure for log messages (array of arrays)
  fh - set to a filehandle to write log messages as logging is done
  num_pass - number of pass messages
  num_fail - number of fail messages
  num_warn - number of warn messages

=cut

sub new {
    my $this=shift;
    my $class=ref($this) || $this;
    my $self={'log'=>[],
              'fh'=>undef,
              'num_pass'=>0,
              'num_fail'=>0,
              'num_warn'=>0,
              @_};
    bless($self, $class);
    return($self);
}    


=head3 num_total()

Return the total number of pass and fail events recorded. Note 
that this doesn't include warnings.

=cut

sub total {
    my $self=shift;
    return( $self->{num_pass}+$self->{num_fail} );
}


=head3 start($title)

Start a test or section and record a title.

=cut

sub start {
    my $self=shift;
    my ($title)=@_;
    return $self->_add('TITLE',$title);
}


=head3 request($url,$type,$content)

Add a note of the HTTP request used in this test. Must specify
the $url, may include the $type (GET|POST) and for POST
the $content.

=cut

sub request {
    my $self=shift;
    my ($url,$type,$content)=@_;
    return $self->_add('REQUEST',$url,$type||'',$content||'');
}


=head3 note($note)

Add note of extra information that doesn't impact validity.

=cut

sub note {
    my $self=shift;
    my ($note)=@_;
    return $self->_add('NOTE',$note);
}


=head3 fail($msg,$longmsg)

Record a failure and increment the $obj->num_fail count. Must have
a message $msg and may optionally include a longer explanation $longmsg.

=cut

sub fail {
    my $self=shift;
    my ($msg,$longmsg)=@_;
    $self->{num_fail}++;
    return $self->_add('FAIL',$msg,$longmsg||'');
}


=head3 warn($msg,$longmsg)

Record a warning and increment the $obj->num_warn count. Must have
a message $msg and may optionally include a longer explanation $longmsg.

=cut

sub warn {
    my $self=shift;
    my ($msg,$longmsg)=@_;
    $self->{num_warn}++;
    return $self->_add('WARN',$msg,$longmsg||'');
}


=head3 pass($msg,$longmsg)

Record a success and increment the $obj->num_pass count. Must have
a message $msg explaining what has passed.

=cut

sub pass {
    my $self=shift;
    my ($msg)=@_;
    $self->{num_pass}++;
    return $self->_add('PASS',$msg);
}


# _add($type,@content)
#
# Add an entry to @{$obj->log} which has type $type and then
# a set of content elements @content (assumed to be scalars).
# Used buy all the pass, fail, warn, start methods.
#
sub _add {
    my $self=shift;
    push( @{$self->{log}}, [@_] );
    if ($self->{fh}) {
        my $type = shift(@_);
        if ($type eq 'TITLE') {
            print {$self->{fh}} "\n### ".join(' : ',@_)."\n\n";
        } else {
            printf {$self->{fh}} ("%-8s ",$type.':');
            print {$self->{fh}} join(' ',@_)."\n";
        }
    }
    return(1);
}

1;
