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
plan tests => 132;
my $ns;

##########################################################################
## create WebService::Nestoria::Search object
##
$ns = WebService::Nestoria::Search->new(
    'country'           => 'uk',
    'encoding'          => 'json',
);
ok($ns && ref($ns), 'created WebService::Nestoria::Search object');

##########################################################################
## simplest search
##
my @results = $ns->results(
    'place_name'        => 'soho',
    'number_of_results' => 10,
);
is(scalar(@results), 10, 'got 10 results for basic search');

##########################################################################
## search parameters
##

my @parameters_uk_soho = (
    # default = uk is fine
    apply { $_->{'country'} = 'uk'; $_->{'place_name'} = 'soho' } (
        { 'number_of_results' => 1,                         },
        { 'page'              => 2                          },
        { 'listing_type'      => 'buy'                      },
        { 'property_type'     => 'flat'                     },
        { 'price_max'         => '100000'                   },
        { 'price_min'         => '100'                      },
        { 'bedroom_max'       => '4'                        },
        { 'bedroom_min'       => '1'                        },
        { 'sort'              => 'newest'                   },
        { 'keywords'          => 'garden'                   },
        { 'keywords_exclude'  => 'garden'                   },
    )
);

my @parameters_es_eixample = (
    ## size is rarely set in the UK, so we use ES here
    apply { $_->{'country'} = 'es'; $_->{'place_name'} = 'eixample'; } (
        { 'size_max'          => '1000'                     },
        { 'size_min'          => '10'                       },
    ),
);

my @parameters_uk_coordinates = (
    ## no placename set for these queries
    apply { $_->{'country'} = 'uk' } (
        {
            'south_west'      => '51.47,-0.14',
            'north_east'      => '50.47,-0.24',
        },
        { 'centre_point'      => '51.47,-0.14',     },
        { 'radius'            => '51.47,-0.14,1km', },
    ),
);

my @parameters = 
    (@parameters_uk_soho, @parameters_es_eixample, @parameters_uk_coordinates);

foreach my $parameters (@parameters) {
    my $request  = $ns->request(%$parameters);
    my $response = $request->fetch;

# uncomment for debugging:
#   print $request->url, "\n";

    my $query_string = join(
        ", ", 
        (
            apply { $_ = "$_: $parameters->{$_}"          }
            sort 
            grep  { $_ ne 'country' && $_ ne 'place_name' }
            keys %$parameters
        )
    );

    ok(
        $response && ($response->status_code == 200), 
        "$query_string - response"
    );
    ok(
        $response->count >= 1,
        "$query_string - result"
    );
};

##########################################################################
## objects and shortcuts
##

$ns = WebService::Nestoria::Search->new(
    'country'           => 'uk',
    'encoding'          => 'json',
    'place_name'        => 'soho',
);

isa_ok($ns,                 'WebService::Nestoria::Search'                  );
isa_ok($ns->request,        'WebService::Nestoria::Search::Request'         );
isa_ok($ns->query,          'WebService::Nestoria::Search::Response'        );
isa_ok(($ns->results)[0],   'WebService::Nestoria::Search::Result'          );
isa_ok($ns->metadata,       'WebService::Nestoria::Search::MetadataResponse');

##########################################################################
## keywords
##

$ns = WebService::Nestoria::Search->new(
    'country'           => 'uk',
);

my @keywords = $ns->keywords;
ok(@keywords, 'got keywords list');
ok(scalar(grep {$_ eq 'garden'} @keywords), "found 'garden' keyword");

##########################################################################
## validation
##

$ns = WebService::Nestoria::Search->new(
    'country'  => 'uk',
    'warnings' => 1,
);

my %validation_tests = (
    'country'             => {
        'bad'  => [ 'fake' ],
        'good' => [ 'uk', 'es', 'de', 'it' ],
    },
    'place_name'          => {
        'bad'  => [ undef ],
        'good' => [ 'soho', 'richmond', 'W12', 'clerkenwell road' ],
    },
    'south_west'          => {
        'bad'  => [ undef, '170,91' ],
        'good' => [ '51.47,-0.14' ],
    },
    'north_east'          => {
        'bad'  => [ undef, '181,89' ],
        'good' => [ '50.47,-0.24' ],
    },
    'centre_point'        => {
        'bad'  => [ undef, '300,300' ],
        'good' => [ '50.47,-0.24' ],
    },
    'radius'              => {
        'bad'  => [ undef, '170,91,1mi', '51.47,-0.14,1lightyear' ],
        'good' => [ '51.47,-0.14,1mi', '51.47,-0.14,2km', ],
    },
    'number_of_results'   => {
        'bad'  => [ undef, -10, 0, 'not a number' ],
        'good' => [ 10, 20, 50 ],
    },
    'page'                => {
        'bad'  => [ undef, -10, 0, 'not a number' ],
        'good' => [ 10, 20, 50 ],
    },
    'listing_type'        => {
        'bad'  => [ undef, 'not a listing type' ],
        'good' => [ 'buy', 'rent', 'share' ],
    },
    'property_type'       => {
        'bad'  => [ undef, 'not a property type' ],
        'good' => [ 'house', 'flat', 'all' ],
    },
    'price_max'           => {
        'bad'  => [ undef, 'not a number', -10 ],
        'good' => [ 10, 20, 30, 'max' ],
    },
    'price_min'           => {
        'bad'  => [ undef, 'not a number', -10 ],
        'good' => [ 10, 20, 30, 'min' ],
    },
    'sort'                => {
        'bad'  => [ undef, 'not a sort' ],
        'good' => [ qw(bedroom_lowhigh bedroom_highlow price_lowhigh price_highlow newest oldest) ],
    },
    'keywords'            => {
        'bad'  => [ undef ],
        'good' => [ 'garden', 'balcony', 'anything' ],
    },
    'version'             => {
        'bad'  => [ undef, '-1' ],
        'good' => [ 1.1, 1.2, 1.3 ],
    },
    'action'              => {
        'bad'  => [ 'not an action' ],
        'good' => [ qw(search_listings echo keywords metadata) ],
    },
    'encoding'            => {
        'bad'  => [ 'not an encoding' ],
        'good' => [ qw(json xml) ],
    },
    'pretty'              => {
        'bad'  => [ -1, 2 ],
        'good' => [ 0, 1 ],
    },
);

my %expected = (
    'bad'  => [ qr/./ ],
    'good' => [ ],
);

foreach my $arg (sort keys %validation_tests) {
    foreach my $opt (qw(bad good)) {
        my $inputs = $validation_tests{$arg}{$opt} || [];
        foreach my $input (@$inputs) {
            
            warnings_like
                { my $r = $ns->request($arg => $input) }
                $expected{$opt},
                sprintf(
                    '%s => %s - %s',
                    $arg, (defined($input) ? $input : 'undef'), $opt
                )
                ;
        }
    }
}
