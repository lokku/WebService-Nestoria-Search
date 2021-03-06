use strict;
use warnings;

use Test::More;
use Test::Warn;
use List::MoreUtils qw(apply);
use WebService::Nestoria::Search Warnings => 1;

require 't/lib/test-lwp-recorder.pl';

##########################################################################
## create WebService::Nestoria::Search::MetadataResponse object
##
my ($ns, $metadata);
$ns = WebService::Nestoria::Search->new(
    'country'           => 'de',
    'encoding'          => 'json',
    'number_of_results' => 10,
);
ok($ns && ref($ns), 'created WebService::Nestoria::Search object');

$metadata = $ns->metadata('place_name' => 'berlin');
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
my @parameters = apply { $_->{listing_type} = 'buy'; $_->{year} = '2015' } (
    ## monthly
    { 'range' => 'monthly', 'month' => '4',                 },
    { 'range' => 'monthly', 'month' => 'Apr',               },
    { 'range' => 'monthly', 'month' => 'April',             },

    ## other parmaters
    { 'range' => 'monthly', 'month' => 4, 'num_beds' => 3,  },
    { 'range' => 'monthly', 'month' => 4, 'per_sqm'  => 1   },
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

    ok(
        $average_price,
        "$query_string - average price - "
          . ( defined($average_price) ? $average_price : 'fail' )
    );
}

done_testing;
