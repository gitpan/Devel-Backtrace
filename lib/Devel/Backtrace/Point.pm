package Devel::Backtrace::Point;
use strict;
use warnings;
use Carp;
use String::Escape qw(printable);

=head1 NAME

Devel::Backtrace::Point - Object oriented access to the information caller()
provides

=head1 SYNOPSIS

    print Devel::Backtrace::Point->new([caller(0)])->to_long_string;

=head1 DESCRIPTION

This class is a nice way to access all the information caller provides on a
given level.  It is used by L<Devel::Backtrace>, which generates an array of
all trace points.

=cut

use base qw(Class::Accessor::Fast);
use overload '""' => \&to_string;
use constant;

BEGIN {
    my @known_fields = (qw(package filename line subroutine hasargs wantarray
        evaltext is_require hints bitmask hinthash));
    # The number of caller()'s return values depends on the perl version.  For
    # instance, hinthash is not available below perl 5.9.  We try and see how
    # many fields are supported
    my $supported_fields_number = () = caller(0)
        or die "Caller doesn't work as expected";

    # If not all known fields are supported, remove some
    while (@known_fields > $supported_fields_number) {
        pop @known_fields;
    }

    # If not all supported fields are known, add placeholders
    while (@known_fields < $supported_fields_number) {
        push @known_fields, "_unknown".scalar(@known_fields);
    }

    constant->import (FIELDS => @known_fields);
}

=head1 METHODS

=head2 $p->package, $p->filename, $p->line, $p->subroutine, $p->hasargs,
$p->wantarray, $p->evaltext, $p->is_require, $p->hints, $p->bitmask,
$p->hinthash

See L<perlfunc/caller> for documentation of these fields.

hinthash is only available in perl 5.9 and higher.  When this module is loaded,
it tests how many values caller returns.  Depending on the result, it adds the
necessary accessors.  Thus, you should be able to find out if your perl
supports hinthash by using L<UNIVERSAL/can>:

    Devel::Backtrace::Point->can('hinthash');

=cut

__PACKAGE__->mk_ro_accessors(FIELDS);

=head2 $p->by_index($i)

You may also access the fields by their index in the list that caller()
returns.  This may be useful if some future perl version introduces a new field
for caller, and the author of this module doesn't react in time.

=cut

sub by_index {
    my ($this, $idx) = @_;
    my $fieldname = (FIELDS)[$idx];
    unless (defined $fieldname) {
        croak "There is no field with index $idx.";
    }
    return $this->$fieldname();
}

=head2 new([caller($i)])

This constructs a Devel::Backtrace object.  The argument must be a reference to
an array holding the return values of caller().  This array must have either
three or ten elements (or eleven if hinthash is supported) (see
L<perlfunc/caller>).

=cut

sub new {
    my $class = shift;
    my ($caller) = @_;

    my %data;

    unless ('ARRAY' eq ref $caller) {
        croak 'That is not an array reference.';
    }

    if (@$caller == (() = FIELDS)) {
        for (FIELDS) {
            $data{$_} = $caller->[keys %data]
        }
    } elsif (@$caller == 3) {
        @data{qw(package filename line)} = @$caller;
    } else {
        croak 'That does not look like the return values of caller.';
    }

    return $class->SUPER::new(\%data);
}

=head2 $tracepoint->to_string()

Returns a string of the form "Blah::subname called from main (foo.pl:17)".
This means that the subroutine C<subname> from package C<Blah> was called by
package C<main> in C<foo.pl> line 17.

If you print a C<Devel::Backtrace::Point> object or otherwise treat it as a
string, to_string() will be called automatically due to overloading.

=cut

sub to_string {
    my $this = shift;

    return $this->subroutine
      . ' called from '
      . $this->package . ' ('
      . $this->filename . ':'
      . $this->line . ')';
}

=head2 $tracepoint->to_long_string()

This returns a string which lists all available fields in a table that spans
several lines.

Example:

    package: main
    filename: /tmp/foo.pl
    line: 6
    subroutine: main::foo
    hasargs: 1
    wantarray: undef
    evaltext: undef
    is_require: undef
    hints: 0
    bitmask: \00\00\00\00\00\00\00\00\00\00\00\00

hinthash is not included in the output, as it is a hash.

=cut

sub to_long_string {
    my $this = shift;
    return join '', grep {
        ! /^_/
    } map {
	"$_: " .
	(defined ($this->{$_}) ? printable($this->{$_}) : 'undef')
	. "\n"
    } FIELDS;
}

=head2 FIELDS

This constant contains a list of all the available field names.  The number of
fields depends on your perl version.

=cut

1
__END__

=head1 SEE ALSO

L<Devel::Backtrace>

=head1 AUTHOR

Christoph Bussenius <pepe@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2007 Christoph Bussenius.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut