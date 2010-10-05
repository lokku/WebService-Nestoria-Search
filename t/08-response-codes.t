use strict;
use warnings;

use Test::More;
use Test::Warn;
use WebService::Nestoria::Search Warnings => 1;

##########################################################################
## require internet connection
##
if (! WebService::Nestoria::Search->test_connection) {
    plan 'skip_all' => 'test requires internet connection';
    exit 0;
}

##########################################################################
## plan
##
plan tests => 11;
my $ns;

##########################################################################
## validation
##

$ns = WebService::Nestoria::Search->new(
    'country'  => 'uk',
    'warnings' => 1,
);

my %response_code_tests = (
    100 => { 'place_name' => 'soho'                         },
    101 => { 'place_name' => 'waterloo'                     },
    110 => { 'place_name' => 'london'                       },
    111 => { 'guid'       => 'g1-TMxATLwADMxAjM0MTN3YDO=k'  },

    200 => { 'place_name' => 'newport'                      },
    201 => { 'place_name' => 'Carmen Sandiago'              },
    202 => { 'place_name' => 'kingbridge'                   },
    210 => { 'radius'     => '0.00,0.00,1km'                },

    900 => {                                                },
    901 => { 'place_name' => 'soho',   'page' => 50         },
    902 => { 'place_name' => 'london', 'page' => 1_000_000  },
);

foreach my $code (sort { $a <=> $b } keys %response_code_tests) {
    my $query = $response_code_tests{$code};

    my $response = $ns->query(%$query);

    is(
        $response->application_response_code,
        $code,
        "got code $code for request - " . sr($query)
    );
}

sub sr {
    my $q = shift;
    return 'empty' if !%$q;
    return join ', ', map { "$_: $q->{$_}" } sort keys %$q;
}
