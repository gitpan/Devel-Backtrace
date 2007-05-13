#!perl

use strict;
use warnings;
use Test::More;

# This script tests whether the scripts in the "examples" directory do print
# what they should print.

BEGIN {
    # Several arguments for open, "-|" needed.
    # This will only work on non-windows, perl >= 5.8.0
    $^O =~ /MSWin32/i
        and plan skip_all => 'This test requires an operating system.';
    local $@;
    eval 'use 5.008_000; 1'
        or plan skip_all => "This test won't work on your perl version.";
}

use File::Spec;

my $exampledir = 'examples';
if (! -d $exampledir) {
    $exampledir = File::Spec->catfile('..', $exampledir);
}
chdir($exampledir) or die "$exampledir: $!";

my @examples = <*.pl>;

plan tests => scalar(@examples);

for my $example (@examples) {
    open my $pipe, '-|', $^X, $example
        or die "run $example: $!";
    my $output = do {local $/; <$pipe>};
    die $! unless defined $output;
    close $pipe or die "$example: exited $?";
    open my $examplefh, '<', $example or die "open $example: $!";
    my $content = do {local $/; <$examplefh>};
    defined $content or die "read $example: $!";
    my ($expected_output) = $content =~ /^Output:\s*^(.*)\Z/ms
        or die "$example corrupt";

    for ($output, $expected_output) {
        # The bitmask is not portable
        s/^bitmask:.*//m;

        # Avoid any newline problems
        $_ = join "\n", m{[^\015\012]+}g;
    }

    is($output, $expected_output, $example);
}
