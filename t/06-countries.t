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
plan tests => 16;

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
        'mx' => 'santa-maria-atzompa',
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

        my ($prev_month, $prev_months_year) = do {
            my (undef, undef, undef, $day, $month, $year, undef, undef, undef) = localtime();
            $month += 1;
            $year += 1900;

            my $months_back = 1;
            if ($day < 7) {
                $months_back = 2;
            }

            my $prev_month = $month - $months_back;
            my $prev_months_year = $year;
            if ($prev_month < 1) {
                $prev_month = 13 - $months_back;
                $prev_months_year = $prev_months_year - 1;
            }

            ($prev_month, $prev_months_year);
        };

        ok(
            $metadata->get_average_price(
                'range'        => 'monthly',
                'year'         => $prev_months_year,
                'month'        => $prev_month,
                'listing_type' => 'buy',
            ),
            "metadata - got average price for $place_name, $country, $prev_months_year-$prev_month"
        );
    }
}
