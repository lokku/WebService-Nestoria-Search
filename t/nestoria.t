use strict;
use warnings;
use Test::More;

plan tests => 25;

use_ok 'WebService::Nestoria::Search';
use_ok 'WebService::Nestoria::Search::Request';
use_ok 'WebService::Nestoria::Search::Response';
use_ok 'WebService::Nestoria::Search::Result';

## Create WebService::Nestoria::Search object
my $ns = new WebService::Nestoria::Search(Country => 'uk');

## Object should be a hashref
ok ( ref $ns, 'object created successfully' );

## Check URL

is ($ns->request->url,
    'http://api.nestoria.co.uk/api?pretty=0&version=1.04&action=search_listings&encoding=json',
    'url correctly set');

## skip after here if not connected to the internet

SKIP : {
    skip ('no connection to the internet', 2)
        unless ( $ns->test_connection() );

    my $count;
    $count = scalar $ns->query(place_name => 'soho')->count;
    ok ( $count <= 20, 'got results' );
    $count = scalar $ns->query(place_name => 'soho', number_of_results => '1')->count;
    ok ( $count <= 1, 'number_of_results works' );

    my @listings = $ns->results(
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
    ok($listing->get_thumb_height(), 'got thumbnail height');
    ok($listing->get_thumb_width(), 'got thumbnail width');
    ok($listing->get_keywords(), 'got keywords');

}
