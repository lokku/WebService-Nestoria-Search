use strict;
use warnings;
use Test::More;
use URI;

plan tests => 34;

my @listings;

## Load Modules (1-4)

use_ok 'WebService::Nestoria::Search';
use_ok 'WebService::Nestoria::Search::Request';
use_ok 'WebService::Nestoria::Search::Response';
use_ok 'WebService::Nestoria::Search::Result';

## Create WebService::Nestoria::Search object (6)
my $ns = new WebService::Nestoria::Search(Country => 'uk');
ok ( ref $ns, 'object created successfully' );

## Check URL (7)

my $uri = new URI('http://api.nestoria.co.uk/api?pretty=0&action=search_listings&encoding=json');
my %correct_params = $uri->query_form;

$uri = new URI ($ns->request->url);
my %params = $uri->query_form;

is_deeply (
    \%correct_params,
    \%params, 
    'url correctly set'
);

## skip after here if not connected to the internet

SKIP : {
    skip ('no connection to the internet', 2)
        unless ( $ns->test_connection() );

    ## Check number_of_results (8-9)

    my $count;
    $count = scalar $ns->query(place_name => 'soho')->count;
    ok ( $count <= 20, 'got results' );
    $count = scalar $ns->query(place_name => 'soho', number_of_results => '1')->count;
    ok ( $count <= 1, 'number_of_results works' );

    ## Check get_* functions (10-23)

    @listings = $ns->results(
        place_name   => 'richmond',
        listing_type  => 'buy',
        property_type => 'flat',
    );

    my $listing = $listings[0];

    ok($listing->get_latitude(), 'got latitude');
    ok($listing->get_longitude(), 'got longitude');
    ok($listing->get_listing_type(), 'got listing type');
    ok($listing->get_property_type(), 'got property type');
    ok($listing->get_datasource_name(), 'got datasource name');
    ok($listing->get_lister_name(), 'got lister name');
    ok($listing->get_lister_url(), 'got lister url');
    ok($listing->get_price(), 'got price');
    ok($listing->get_price_currency(), 'got currency');
    ok($listing->get_price_formatted(), 'got formatted price');
    ok($listing->get_title(), 'got title');
    ok($listing->get_summary(), 'got summary');
    ok($listing->get_bedroom_number(), 'got bedroom number');
    ok($listing->get_thumb_url(), 'got thumbnail url');
    #ok($listing->get_thumb_height(), 'got thumbnail height');
    #ok($listing->get_thumb_width(), 'got thumbnail width');
    ok($listing->get_keywords(), 'got keywords');

    ## Check sorting (24-25)

    my @price_sort = $ns->results('place_name' => 'soho', 'sort' => 'price_lowhigh');
    my @price_check = sort { $a->get_price <=> $b->get_price } @price_sort;

    is_deeply (
        \@price_sort,
        \@price_check,
        'results sorted by price correctly'
    );

    my @bedroom_sort = $ns->results('place_name' => 'soho', 'sort' => 'bedroom_highlow');
    my @bed_check = sort { $b->get_bedroom_number <=> $a->get_bedroom_number } @bedroom_sort;
    
    is_deeply (
        \@bedroom_sort,
        \@bed_check,
        'results sorted by number of bedrooms correctly'
    );

    ## Check keywords (26-27)

    my @garden_houses = $ns->results('place_name' => 'sw7', 'keywords' => 'garden');

    my $gardens = 0;
    foreach my $house (@garden_houses) {
        if ($house->get_keywords =~ m/garden/i) {
            $gardens++;
        }
    }
    is (
        $gardens,
        scalar @garden_houses,
        'used keywords list to find houses with gardens'
    );

    my @non_mews_houses = $ns->results('place_name' => 'sw7', 'keywords_exclude' => 'mews');

    my $mews = scalar @non_mews_houses;
    foreach my $house (@non_mews_houses) {
        if ($house->get_keywords =~ m/mews/i) {
            $mews--;
        }
    }
    is (
        $mews,
        scalar @non_mews_houses,
        'used keywords_exclude list to find words not in a mews'
    );

    ## Test Version Switching (28-29)

    my $result;

    $ns = new WebService::Nestoria::Search(version => 1.01);
    ($result) = $ns->results(place_name => 'soho');
    is (
        $result->get_keywords,
        undef,
        'got no keywords for version 1.01 request'
    );

    $ns = new WebService::Nestoria::Search(version => 1.02);
    ($result) = $ns->results(place_name => 'soho');
    ok (
        $result->get_keywords,
        'got keywords for version 1.02 request'
    );

    ## Test Spain (30-31)

    $ns = new WebService::Nestoria::Search(country => 'es');
    ok ($ns->test_connection, 'got echo from spanish API' );

    @listings = $ns->results('place_name' => 'tenerife');
    ok (scalar @listings, 'got listings for tenerife');

    
    ## Test Keywords (32-33)

    my @keywords = ();

    $ns = new WebService::Nestoria::Search(country => 'uk');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'cottage' } @keywords), 'retreived list of uk keywords');
    
    $ns = new WebService::Nestoria::Search(country => 'es');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'garaje' } @keywords), 'retreived list of es keywords');

    ## Test Case Insensitive Parameters (34)

    $ns = new WebService::Nestoria::Search(country => 'uk', PLACE_NAME => 'soho', AcTiOn => 'search_listings', NUMBER_of_RESULTS => '3');
    is (scalar ($ns->results), 3, 'queried with parameters using weird cases');
}
