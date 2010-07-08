use strict;
use warnings;

use Test::More;
plan skip_all => "Set WNS_AUTHOR_TESTS to run WebService::Nestoria::Search author tests" if !$ENV{'WNS_AUTHOR_TESTS'};

eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;

all_pod_files_ok();
