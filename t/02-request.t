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
plan tests => 9;
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
like($response->get_json, qr/"response":{/, 'got json back');

$req = $ns->request('place_name' => 'soho', 'encoding' => 'xml');
$response = $req->fetch;
isa_ok($response, 'WebService::Nestoria::Search::Response');
like($response->get_xml, qr/<response/, 'got xml back');
