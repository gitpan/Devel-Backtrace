#!perl
use strict;
use warnings;
use Devel::DollarAt;

eval '0/0';

print "Error line is ", $@->line, "\n";
print "Error text is $@";

__END__

Output:

Error line is 2
Error text is Illegal division by zero at (eval 3) line 2.
