package HTTP::OAIPMH::Log;

=head1 NAME

HTTP::OAIPMH::Log - Log of validation results

=head1 SYNOPSIS

Validation logging for L<HTTP::OAIPMH::Validator>. Stores log of information
as an array of entries in $self->log, where each entry is itself an array
where the first element is the type (indicated by a string) and then additional
information.

Also supports output of a text summary during operation is $self->fh is 
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

sub start {
    my $self=shift;
    my ($title)=@_;
    $self->add('TITLE',$title);
}

# A note of the request used in this test
sub request {
    my $self=shift;
    my ($url,$type,$content)=@_;
    $self->add('REQUEST',$url,$type||'',$content||'');
}

# A note of extra information that doesn't impact validity
sub note {
    my $self=shift;
    my ($note)=@_;
    $self->add('NOTE',$note);
}

sub fail {
    my $self=shift;
    my ($msg,$longmsg)=@_;
    $self->{num_fail}++;
    $self->add('FAIL',$msg,$longmsg||'');
}

sub warn {
    my $self=shift;
    my ($msg,$longmsg)=@_;
    $self->{num_warn}++;
    $self->add('WARN',$msg,$longmsg||'');
}

sub pass {
    my $self=shift;
    my ($msg)=@_;
    $self->{num_pass}++;
    $self->add('PASS',$msg);
}

sub add {
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
}

1;
