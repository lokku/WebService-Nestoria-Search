use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

if ($ENV{'PERLCRITIC'}) {
    my $msg = 'Test::Perl::Critic skipped: ENV defines custom .perlcriticrc';
    plan(skip_all => $msg);
    exit;
}

eval { require Test::Perl::Critic; };
if ( $EVAL_ERROR ) {
    my $msg = 'Test::Perl::Critic required to criticise code';
    plan(skip_all => $msg);
    exit;
}

Test::Perl::Critic->import;
all_critic_ok();
