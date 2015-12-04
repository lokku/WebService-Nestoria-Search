# use Test::LWP::Recorder to avoid running live tests for people installing the
# module, or CPAN Testers.

use lib 'inc';
use Test::LWP::Recorder;

my $TestUA = Test::LWP::Recorder->new({
    record => $ENV{LWP_RECORD},
    cache_dir => 't/LWPCache',
});

WebService::Nestoria::Search->override_user_agent($TestUA);

if (!$ENV{LWP_RECORD}) {
    WebService::Nestoria::Search->override_sleep_time(0);
}

1;
