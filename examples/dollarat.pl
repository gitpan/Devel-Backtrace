#!perl
use strict;
use warnings;
use Devel::DollarAt;

eval '0/0; "foo"';

# Don't worry about the "foo"; it serves to make perl 5.8 and 5.10 output the
# same line number so I can use this example in the tests.

print "Error line is ", $@->line, "\n";
print "Error text is $@";

__END__

Output:

Error line is 1
Error text is Illegal division by zero at (eval 3) line 1.
