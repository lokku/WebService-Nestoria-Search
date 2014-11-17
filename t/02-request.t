use strict;
use warnings;

use Test::More;
use Test::Warn;
use List::MoreUtils qw(apply);
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
plan tests => 14;
my ($ns, $req, $response);

##########################################################################
## create WebService::Nestoria::Search::Request object
##
$ns = WebService::Nestoria::Search->new(
    'country'           => 'uk',
    'encoding'          => 'json',
);
ok($ns && ref($ns), 'created WebService::Nestoria::Search object');

$req = $ns->request('place_name' => 'soho');
ok($req && ref($req), 'created WebService::Nestoria::Search::Request object');

##########################################################################
## uri/url
##
my $uri = $req->uri;
isa_ok($uri, 'URI');
is($uri->host, 'api.nestoria.co.uk', 'got correct host for uri');

my $url = $req->url;
like($url, qr{^http://api[.]nestoria[.]co[.]uk/api[?]}, 'got correct url');

##########################################################################
## fetch
##
$req = $ns->request('place_name' => 'soho', 'encoding' => 'json');
$response = $req->fetch;
isa_ok($response, 'WebService::Nestoria::Search::Response');
like($response->get_json, qr/"response":\{/, 'got json back');

$req = $ns->request('place_name' => 'soho', 'encoding' => 'xml');
$response = $req->fetch;
isa_ok($response, 'WebService::Nestoria::Search::Response');
like($response->get_xml, qr/<response/, 'got xml back');

##########################################################################
## last_request_uri/last_request_url
##
my $expected_last_uri = URI->new('http://api.nestoria.co.uk/api?warnings=1&country=uk&pretty=0&action=search_listings&place_name=soho&encoding=xml');

my $last_request_uri = $ns->last_request_uri;
isa_ok($last_request_uri, 'URI');

is(
    $last_request_uri->host,
    $expected_last_uri->host,
    'got correct uri for last request - host'
);

## using is_deeply() here because comparing with URI::as_string() or URI::eq()
## is susceptible to differences in hash key order which changes the order of
## the query form parameters in the URL.
is_deeply(
    { $last_request_uri->query_form  },
    { $expected_last_uri->query_form },
    'got correct uri for last request - query form'
);

my $last_request_url = $ns->last_request_url;

is(
    URI->new($last_request_url)->host,
    $expected_last_uri->host,
    'got correct url for last request - host'
);

## using is_deeply() here because comparing with URI::as_string() or URI::eq()
## is susceptible to differences in hash key order which changes the order of
## the query form parameters in the URL.
is_deeply(
    { URI->new($last_request_url)->query_form },
    { $expected_last_uri->query_form          },
    'got correct url for last request'
);
