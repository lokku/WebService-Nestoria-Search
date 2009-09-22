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
plan tests => 10;
my ($ns, $metadata);

##########################################################################
## create WebService::Nestoria::Search::MetadataResponse object
##
$ns = WebService::Nestoria::Search->new(
    'country'           => 'es',
    'encoding'          => 'json',
    'number_of_results' => 10,
);
ok($ns && ref($ns), 'created WebService::Nestoria::Search object');

$metadata = $ns->metadata('place_name' => 'eixample');
ok(
    $metadata && ref($metadata),
    'created WebService::Nestoria::Search::MetadataResponse object'
);

##########################################################################
## get_hashref/get_metadata
##
is(ref $metadata->get_hashref, 'HASH', 'get_hashref returns a hash reference');
is(ref $metadata->get_metadata, 'HASH', 'get_metadata returns a hash reference');

##########################################################################
## get_average_price
##

# try with no parameters
my $average_price = $metadata->get_average_price('listing_type' => 'rent', 'range' => 'monthly');
ok($average_price, "no paramters - average price - $average_price");

# try with parameters
my @parameters = apply { $_->{listing_type} = 'rent'; $_->{year} = '2008' } (
    ## monthly
    { 'range' => 'monthly', 'month' => '1',                 },
    { 'range' => 'monthly', 'month' => 'Feb',               },
    { 'range' => 'monthly', 'month' => 'March',             },

    ## other parmaters
    { 'range' => 'monthly', 'month' => 1, 'num_beds' => 3,  },
    { 'range' => 'monthly', 'month' => 1, 'per_sqm' => 1    },
);

foreach my $parameters (@parameters) {
    my $average_price = $metadata->get_average_price(%$parameters);

    my $query_string = join(
        ", ", 
        (
            apply { $_ = "$_: $parameters->{$_}"         }
            sort 
            grep  { $_ ne 'listing_type' && $_ ne 'year' }
            keys %$parameters
        )
    );

    ok($average_price, "$query_string - average price - $average_price");
}
