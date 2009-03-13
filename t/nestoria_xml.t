use strict;
use warnings;
use Test::More;
use URI;

my $TESTS = 50;

plan tests => $TESTS;

my @listings;

## Load Modules

use_ok 'WebService::Nestoria::Search';
use_ok 'WebService::Nestoria::Search::Request';
use_ok 'WebService::Nestoria::Search::Response';
use_ok 'WebService::Nestoria::Search::Result';
use_ok 'WebService::Nestoria::Search::MetadataResponse';

## Create WebService::Nestoria::Search object
my $ns = new WebService::Nestoria::Search(Country => 'uk', encoding => 'xml');
ok ( ref $ns, 'object created successfully' );

## Check URL

my $uri = new URI('http://api.nestoria.co.uk/api?pretty=0&action=search_listings&encoding=xml');
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

    skip ('no connection to the internet', ($TESTS-7))
        unless ( $ns->test_connection() );

    ## Check number_of_results

    my $count;
    $count = scalar $ns->query(place_name => 'soho')->count;
    ok ( $count <= 20, 'got results' );
    $count = scalar $ns->query(place_name => 'soho', number_of_results => '1')->count;
    ok ( $count <= 1, 'number_of_results works' );

    ## Check get_* functions

    @listings = $ns->results(
        place_name   => 'richmond',
        listing_type  => 'buy',
        property_type => 'flat',
    );

    my $listing = $listings[0];

    my @listing_fields_required = qw(
        datasource_name keywords   latitude
        lister_name     lister_url listing_type
        longitude       price      price_currency 
        price_formatted price_type property_type
        summary         title
    );

    foreach my $field (@listing_fields_required) {
        no strict "refs";
        my $func = "get_$field";
        ok($listing->$func, "got $field");
    }
    
    ## Check for listings that HAS a photo - fix this to do a proper test
    ## Possibly put in the list of the no_photo URLs & look for these in results?
    my @photo_check = $ns->results('place_name' => 'soho', 'has_photo' => '1');
    @photo_check = $ns->results('place_name' => 'soho', 'has_photo' => '0');

    ## Steal a GUID from above query & use it to retrieve a listing
    my $random_result = int(rand(scalar(@photo_check)));
    my $guid = $photo_check[$random_result]->get_guid;
    my $title = $photo_check[$random_result]->get_title;
    my @guid_check = $ns->results('place_name' => 'soho', 'guid' => $guid);

    is ( 
        $title, 
        $guid_check[0]->get_title, 
        "GUID correctly fetched"
    );

    ## Check sorting

    my @price_sort = $ns->results('place_name' => 'soho', 'sort' => 'price_lowhigh');
    my @price_check = sort { $a->get_price <=> $b->get_price } @price_sort;

    is_deeply (
        \@price_sort,
        \@price_check,
        'results sorted by price'
    );

    my @bedroom_sort = $ns->results('place_name' => 'soho', 'sort' => 'bedroom_highlow');
    my @bed_check = sort { $b->get_bedroom_number <=> $a->get_bedroom_number } @bedroom_sort;
    
    is_deeply (
        \@bedroom_sort,
        \@bed_check,
        'results sorted by number of bedrooms'
    );

    ## for newest/oldest we can only check the response 'sort' field,
    ## because there are no time data for listings returned
    my $newsort_response = $ns->query('place_name' => 'soho', 'sort' => 'newest');
    is $newsort_response->get_hashref->{'request'}{'sort'}, 'newest', 'results sorted by newest';
  
    my $oldsort_response = $ns->query('place_name' => 'soho', 'sort' => 'oldest');
    is $oldsort_response->get_hashref->{'request'}{'sort'}, 'oldest', 'results sorted by oldest';

    ## coordinate search / radius parameter
    my @radius_results = $ns->results('radius' => '51.473685,-0.148315,2km');
    my @centre_point_results = $ns->results('centre_point' => '51.473685,-0.148315');

    is (
        $radius_results[0]->get_title,
        $centre_point_results[0]->get_title,
        'got results by radius and centre point'
    );

    ## Bounding box parameter
    my @bound_results = $ns->results('south_west' => '51.473685,-0.148315', 'north_east' => '50.473685,-0.248315');
    ok (
        $bound_results[0]->get_title,
        'got results using bounding box'
    );


    ## Check attribution special field

    my $basic_response = $ns->query;
    is $basic_response->attribution->{'link_to_img'}, 'http://www.nestoria.co.uk', 'got attribution data';
    is $basic_response->attribution_html, '<a href="http://www.nestoria.co.uk"><img height="20" width="200" src="http://static.nestoria.co.uk/i/realestate/uk/en/pb.png">', 'got attribution as html';
    is $basic_response->attribution_xhtml, '<a href="http://www.nestoria.co.uk"><img src="http://static.nestoria.co.uk/i/realestate/uk/en/pb.png" style="height: 20px; width: 200px;" />', 'got attribution as xhtml';

    ## Check keywords

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

    ## Test Spain

    $ns = new WebService::Nestoria::Search(country => 'es', encoding => 'xml');
    ok ($ns->test_connection, 'got echo from Spanish API' );

    @listings = $ns->results('place_name' => 'Madrid');
    ok (scalar @listings, 'got listings for Madrid');

    ## Test Germany

    $ns = new WebService::Nestoria::Search(country => 'de', encoding => 'xml');
    ok ($ns->test_connection, 'got echo from German API' );

    @listings = $ns->results('place_name' => 'Berlin');
    ok (scalar @listings, 'got listings for Berlin');

    ## Test Italy

    $ns = new WebService::Nestoria::Search(country => 'it', encoding => 'xml');
    ok ($ns->test_connection, 'got echo from Italian API' );

    @listings = $ns->results('place_name' => 'Firenze');
    ok (scalar @listings, 'got listings for Firenze');
    
    ## Test Keywords

    my @keywords = ();

    $ns = new WebService::Nestoria::Search(country => 'uk', encoding => 'xml');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'cottage' } @keywords), 'retrieved list of uk keywords');
    
    $ns = new WebService::Nestoria::Search(country => 'es', encoding => 'xml');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'garaje' } @keywords), 'retrieved list of es keywords');

    $ns = new WebService::Nestoria::Search(country => 'de', encoding => 'xml');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'garten' } @keywords), 'retrieved list of de keywords');

    $ns = new WebService::Nestoria::Search(country => 'it', encoding => 'xml');
    @keywords = $ns->keywords;
    ok ((grep { $_ eq 'cantina' } @keywords), 'retrieved list of it keywords');

    ## Test Metadata
    
    $ns = new WebService::Nestoria::Search(country => 'uk', encoding => 'xml');

    my $metadata_response = $ns->metadata(place_name => 'soho');

    is ref $metadata_response->get_metadata, 'HASH', 'got metadata hashref';

    my $avg_1bed_flat_rent_latest = $metadata_response->get_average_price('num_beds' => '1', 'property_type' => 'property', 'listing_type' => 'rent', 'range' => 'monthly');
    ok $avg_1bed_flat_rent_latest, "got average price for 1 bed flats to rent in soho now - $avg_1bed_flat_rent_latest";
    
    my $avg_1bed_flat_property_oct_2007 = $metadata_response->get_average_price('num_beds' => '1', 'property_type' => 'property', 'listing_type' => 'rent', 'range' => 'monthly', 'year' => '2007', 'month' => 'Oct');

    ok $avg_1bed_flat_property_oct_2007, "got average price for 1 bed properties to rent in soho in October 2007 - $avg_1bed_flat_property_oct_2007";

    my $avg_1bed_property_rent_apr_2008 = $metadata_response->get_average_price('num_beds' => '1', 'property_type' => 'property', 'listing_type' => 'rent', 'range' => 'monthly', 'year' => '2008', 'month' => '4');

    ok $avg_1bed_property_rent_apr_2008, "got average price for 1 bed properties to rent in soho in 04/2008 - $avg_1bed_property_rent_apr_2008";

    ## Test Case Insensitive Parameters

    $ns = new WebService::Nestoria::Search(country => 'uk', PLACE_NAME => 'soho', AcTiOn => 'search_listings', NUMBER_of_RESULTS => '3', Encoding => 'xml');
    is (scalar ($ns->results), 3, 'queried with parameters using weird cases');
}
