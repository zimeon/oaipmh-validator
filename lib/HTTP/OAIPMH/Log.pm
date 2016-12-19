package HTTP::OAIPMH::Log;

=head1 NAME

HTTP::OAIPMH::Log - Log of validation results

=head1 SYNOPSIS

Validation logging for L<HTTP::OAIPMH::Validator>. Stores log of information
as an array of entries in $obj->log, where each entry is itself an array
where the first element is the type (indicated by a string) and then additional
information.

Also supports output of a text summary (markdown) and/or JSON data
during operation if the $obj->filehandles array is set to include one
or more filehandle and types for output.

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
use CGI qw(escapeHTML);
use JSON qw(encode_json);
use base qw(Class::Accessor::Fast);
HTTP::OAIPMH::Log->mk_accessors( qw(log filehandles num_pass num_fail num_warn) );

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
    # uncoverable condition false
    my $class=ref($this) || $this;
    my $self={'log'=>[],
              'filehandles'=>[],
              'num_pass'=>0,
              'num_fail'=>0,
              'num_warn'=>0,
              @_};
    bless($self, $class);
    return($self);
}


=head3 fh(@fhspecs)

Set the list of filehandle specs that will be written to, clearing
any that already exist. Each entry in the @fhspec array should be a 
either a filehandle or an arrayref [$fh,$type] used to call
$self->add_fh($fh,$type) to set the type as well.

Returns number of filehandles in the list to write to.

=cut

sub fh {
    my $self=shift;
    if (@_) {
	$self->{filehandles} = [];
	foreach my $fhspec (@_) {
	    $fhspec = [$fhspec] unless (ref($fhspec) eq 'ARRAY');
	    $self->add_fh(@$fhspec);
	}
    }
    return(scalar(@{$self->{filehandles}}));
}


=head3 add_fh($fh,$type)

Add a filehandle to the logger. If $type is set equal to 'json' then
JSON will be written, els if 'html then HTML will be written, otherwise
text is output in markdown format. The call is ignored unless $fh is True.

=cut

sub add_fh {
    my $self=shift;
    my ($fh,$type)=@_;
    return() if (not $fh);
    $type ||= 'md';
    push(@{$self->{filehandles}},{'fh'=>$fh,'type'=>$type});
    return($fh);
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


=head3 fail($msg)

Record a failure and increment the $obj->num_fail count.

=cut

sub fail {
    my $self=shift;
    my ($msg)=@_;
    $self->{num_fail}++;
    return $self->_add('FAIL',$msg);
}


=head3 warn($msg)

Record a warning and increment the $obj->num_warn count.

=cut

sub warn {
    my $self=shift;
    my ($msg)=@_;
    $self->{num_warn}++;
    return $self->_add('WARN',$msg);
}


=head3 pass($msg)

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
# Used by all the pass, fail, warn, start methods.
#
# In addition to recording the data in $self->{log} array, will
# write output in markdown, HTML or JSON to each of the filehandles
# in $self->filehandles.
#
sub _add {
    my $self=shift;
    push( @{$self->{log}}, [@_] );
    if (scalar($self->filehandles)>0) {
        $self->_write_to_filehandles([@_], $self->filehandles);
    }
    return(1);
}


# _write_to_filehandles($entry, $filehandles) - write one entry
# to zero of more filehandles with formats as specified in
# $filehandles data.
#
sub _write_to_filehandles {
    my $self = shift(@_);
    my ($entry, $filehandles) = @_;
    my $type = shift(@$entry);
    my $md_prefix = '';
    my $md_suffix = "\n";
    my $msg = join(' ',@$entry);
    foreach my $fhd (@$filehandles) {
        if ($fhd->{'type'} eq 'json') {
            $self->_write_json($fhd->{'fh'},$type,$msg);
        } elsif ($fhd->{'type'} eq 'html') {
            $self->_write_html($fhd->{'fh'},$type,$msg);
        } else {
            if ($type eq 'TITLE') {
                $md_prefix = "\n### ";
                $md_suffix = "\n\n";
            } else {
                $md_prefix = sprintf("%-8s ",$type.':');
            }
            $self->_write_md($fhd->{'fh'},$md_prefix,$msg,$md_suffix);
        }
    }
    return(1);
}


# _write_md($fh, @msg) - Write a markdown log entry to $fh, combining
# all @msg by simple concatenation to make the string
#
sub _write_md {
    my $self=shift;
    my $fh=shift;
    print {$fh} join('',@_);
}

# _write_html($fh,$type,$msg) - Write an HTML log entry to $fh, using
# classes to allow CSS styling
#
sub _write_html {
    my $self=shift;
    my ($fh,$type,$msg)=@_;
    if ($type eq 'TITLE') {
        print {$fh} '<h3 class="oaipmh-log-title">'.$msg."</h3>\n";
    } else {
        print {$fh} '<div class="oaipmh-log-line oaipmh-log-'.$type.'">'.
                    '<span class="oaipmh-log-num">'.scalar(@{$self->{log}}).'</span> '.
                    '<span class="oaipmh-log-type">'.$type.'</span> '.
                    '<span class="oaipmh-log-msg">'.$msg."</span></div>\n";
    }
}

# _write_json($fh,$type,$msg) - Write a one-line JSON object to
# $fh, terminate with \n.
#
sub _write_json {
    my $self=shift;
    my ($fh,$type,$msg)=@_;
    print {$fh} encode_json({ type=>$type, msg=>$msg,
                              num=>scalar(@{$self->{log}}),
                              pass=>$self->num_pass,
                              fail=>$self->num_fail,
                              warn=>$self->num_warn,
                              timestamp=>''.localtime() })."\n";
}


=head3 last_match($regex)

Return last log entry where the message matches $regex, else
empty return.

=cut

sub last_match {
    my $self=shift;
    my ($regex)=@_;
    foreach my $entry (reverse(@{$self->log})) {
        if ($entry->[1]=~$regex) {
            return($entry);
        }
    }
    return;
}

1;
