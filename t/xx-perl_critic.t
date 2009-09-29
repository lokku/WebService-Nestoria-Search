use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

my $msg;

if ($ENV{'PERLCRITIC'}) {
    $msg = 'Test::Perl::Critic skipped: ENV defines custom .perlcriticrc';
}
if (-f "$ENV{HOME}/.perlcriticrc") {
    $msg = 'Test::Perl::Critic skipped: ~/.perlcriticrc found, do not want';
}

eval { require Test::Perl::Critic };
if ($EVAL_ERROR) {
    $msg = 'Test::Perl::Critic required to criticise code';
}


if ($msg) {
    plan(skip_all => $msg);
    exit;
}
else {
    Test::Perl::Critic->import;
    all_critic_ok();
}
