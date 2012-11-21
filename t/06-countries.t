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
plan tests => 15;

##########################################################################
## search_listings
##
{
    my %countries = (
        'uk' => 'oxford',
        'es' => 'bilbao',
        'it' => 'roma',
        'de' => 'koeln',
        'fr' => 'lyon',
        'br' => 'sao-paulo',
        'in' => 'mumbai',
    );

    foreach my $country (sort keys %countries) {
        my $ns = WebService::Nestoria::Search->new(
            'country'           => $country,
            'encoding'          => 'json',
            'number_of_results' => 10,
        );

        my $place_name = $countries{$country};
        my @results = $ns->results('place_name' => $place_name);

        is @results, 10, "search_listings - got 10 results for $place_name, $country";
    }
}

##########################################################################
## metadata
##
{
    my %countries = (
        'uk' => 'oxford',
        'es' => 'bilbao',
        'it' => 'roma',
        'de' => 'koeln',
        'fr' => 'lyon',
        'au' => 'newcastle',
        'br' => 'sao-paulo',
        'in' => 'mumbai',
    );

    foreach my $country (sort keys %countries) {
        my $ns = WebService::Nestoria::Search->new(
            'country'           => $country,
            'encoding'          => 'json',
        );

        my $place_name = $countries{$country};
        my $metadata = $ns->metadata(
            'place_name' => $place_name,
        );

        ok(
            $metadata->get_average_price(
                'range'        => 'monthly',
                'year'         => 2011,
                'month'        => 9,
                'listing_type' => 'buy',
            ),
            "metadata - got average price for $place_name, $country"
        );
    }
}
