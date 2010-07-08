use strict;
use warnings;

use Test::More;
plan skip_all => "Set WNS_AUTHOR_TESTS to run WebService::Nestoria::Search author tests" if !$ENV{'WNS_AUTHOR_TESTS'};

eval { require Test::Kwalitee; Test::Kwalitee->import() };
plan( skip_all => 'Test::Kwalitee not installed; skipping' ) if $@;

