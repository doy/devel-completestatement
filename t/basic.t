#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Devel::CompleteStatement;

ok(Devel::CompleteStatement::complete_statement('if ($x) { $y }'));
ok(!Devel::CompleteStatement::complete_statement('if ($x) { $y'));

ok(Devel::CompleteStatement::complete_statement('if ($x) { BEGIN { die } }'));
ok(!Devel::CompleteStatement::complete_statement('if ($x) { BEGIN { die }'));

done_testing;
