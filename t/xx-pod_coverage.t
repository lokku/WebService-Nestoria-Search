use strict;
use warnings;

use Test::More;
plan skip_all => "Set WNS_AUTHOR_TESTS to run WebService::Nestoria::Search author tests" if !$ENV{'WNS_AUTHOR_TESTS'};

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;

plan tests => 1;

pod_coverage_ok('WebService::Nestoria::Search');
