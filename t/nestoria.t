use strict;
use warnings;
use Test::More;

plan tests => 8;

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
    'http://api.nestoria.co.uk/api?version=1.00&action=search_listings&encoding=json',
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
}
