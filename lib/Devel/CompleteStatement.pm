package Devel::CompleteStatement;
use strict;
use warnings;
use 5.016;
# ABSTRACT: determine if a string of perl code is complete

use XSLoader;
XSLoader::load;

use Exporter 'import';
our @EXPORT = ('complete_statement');

sub _call_parse {
    eval { _parse() };
}

=func complete_statement

=cut

1;
