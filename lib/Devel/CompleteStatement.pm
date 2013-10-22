package Devel::CompleteStatement;
use strict;
use warnings;
# ABSTRACT: foo

use XSLoader;
XSLoader::load;

sub _call_parse {
    eval { _parse() };
}

1;
