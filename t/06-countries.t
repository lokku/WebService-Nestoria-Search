use strict;
use warnings;

use Test::More;
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
my %countries = (
    'uk' => 'oxford',
    'es' => 'eixample',
    'it' => 'firenze',
    'de' => 'koeln',
    'au' => 'newcastle',
    'fr' => 'lyon',
    'br' => 'sao-paulo',
    'in' => 'mumbai',
);

plan tests => scalar keys %countries;

##########################################################################
## tests
##

foreach my $country (sort keys %countries) {
    my $ns = WebService::Nestoria::Search->new(
        'country'           => $country,
        'encoding'          => 'json',
        'number_of_results' => 10,
    );

    my $place_name = $countries{$country};
    my @results = $ns->results('place_name' => $place_name);
    is @results, 10, "got 10 results for $country / $place_name";
}
