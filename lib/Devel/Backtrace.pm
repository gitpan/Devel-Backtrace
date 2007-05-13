package Devel::Backtrace;
use strict;
use warnings;
use Devel::Backtrace::Point;

use overload '""' => \&to_string;

=head1 NAME

Devel::Backtrace - Object-oriented backtrace

=head1 VERSION

This is version 0.04.

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

    my $backtrace = Devel::Backtrace->new;

    print $backtrace; # use automatic stringification
                      # See EXAMPLES to see what the output might look like

    print $backtrace->point(0)->line;

=head1 METHODS

=head2 Devel::Backtrace->new([$start])

Constructs a new C<Devel::Backtrace> which is filled with all the information
C<caller($i)> provides, where C<$i> starts from C<$start>.  If no argument is
given, C<$start> defaults to 0.

If C<$start> is 1 (or higher), the backtrace won't contain the information that
(and where) Devel::Backtrace::new() was called.

=cut

sub new {
    my $class = shift;
    my ($start) = @_;

    $start = 0 unless defined $start;

    my @backtrace;
    for (my $deep = $start; my @caller = caller($deep); ++$deep) {
	push @backtrace, \@caller;
    }
    $_ = Devel::Backtrace::Point->new($_) for @backtrace;

    return bless \@backtrace, $class;
}

=head2 $backtrace->point($i)

Returns the i'th tracepoint as a L<Devel::Backtrace::Point> object (see its documentation
for how to access every bit of information).

Note that the following code snippet will print the information of
C<caller($start+$i)>:

    print Devel::Backtrace->new($start)->point($i)

=cut

sub point {
    my $this = shift;
    my ($i) = @_;
    return $this->[$i];
}

=head2 $backtrace->points()

Returns a list of all tracepoints.  In scalar context, the number of
tracepoints is returned.

=cut

sub points {
    my $this = shift;
    return @$this;
}

=head2 $backtrace->skipme([$package])

This method deletes all leading tracepoints that contain information about calls
within C<$package>.  Afterwards the C<$backtrace> will look as though it had
been created with a higher value of C<$start>.

If the optional parameter C<$package> is not given, it defaults to the calling
package.

The effect is similar to what the L<Carp> module does.

This module ships with an example "skipme.pl" that demonstrates how to use this
method.

=cut

sub skipme {
    my $this = shift;
    my $package = @_ ? $_[0] : caller;

    my $skip;
    $skip = shift @$this while @$this and $package eq $this->point(0)->package;
    return $skip;
}

=head2 $backtrace->to_string()

Returns a string that contains one line for each tracepoint.  It will contain
the information from C<Devel::Backtrace::Point>'s to_string() method.  To get
more information, use the to_long_string() method.

Note that you don't have to call to_string() if you print a C<Devel::Backtrace>
object or otherwise treat it as a string, as the stringification operator is
overloaded.

See L</EXAMPLES>.

=cut

sub to_string {
    my $this = shift;
    return join '', map "$_\n", $this->points;
}


=head2 $backtrace->to_long_string()

Returns a very long string that contains several lines for each trace point.
The result will contain every available bit of information.  See
L<Devel::Backtrace::Point/to_long_string> for an example of what the result
looks like.

=cut

sub to_long_string {
    my $this = shift;
    return join "\n", map $_->to_long_string, $this->points;
}


1
__END__

=head1 EXAMPLES

A sample stringification might look like this:

    Devel::Backtrace::new called from main (foo.pl:10)
    main::bar called from main (foo.pl:6)
    main::foo called from main (foo.pl:13)

=head1 SEE ALSO

L<Devel::StackTrace> does mostly the same as this module.  I'm afraid I haven't
noticed it until I uploaded this module.

L<Carp::Trace> is a simpler module which gives you a backtrace in string form.

=head1 AUTHOR

Christoph Bussenius <pepe@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2007 Christoph Bussenius.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
