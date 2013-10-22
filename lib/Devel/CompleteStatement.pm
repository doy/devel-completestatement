package Devel::CompleteStatement;
use strict;
use warnings;
use 5.016;
# ABSTRACT: foo

use XSLoader;
XSLoader::load;

use Exporter 'import';
our @EXPORT = ('complete_statement');

sub _call_parse {
    eval { _parse() };
}

1;
