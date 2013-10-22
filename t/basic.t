#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Devel::CompleteStatement 'complete_statement';

is(complete_statement('if ($x) { $y }'), 1);
is(complete_statement('if ($x) { $y'), '');
is(complete_statement('if ($x) { $y '), '');

is(complete_statement('if ($x) { $y } }'), undef);
is(complete_statement('if ($x) { BEGIN { die } }'), undef);
is(complete_statement('if ($x) { BEGIN { die }'), undef);

done_testing;
