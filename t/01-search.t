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
plan tests => 45;
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
    'place_name'        => 'oxford',
    'number_of_results' => 10,
);
is(scalar(@results), 10, 'got 10 results for basic search');

##########################################################################
## search parameters
##

my @parameters_uk_richmond = (
    # default = uk is fine
    apply { $_->{'country'} = 'uk'; $_->{'place_name'} = 'richmond' } (
        { 'number_of_results' => 1,                         },
        { 'page'              => 2                          },
        { 'listing_type'      => 'buy'                      },
        { 'property_type'     => 'flat'                     },
        { 'price_max'         => '600000'                   },
        { 'price_min'         => '100'                      },
        { 'bedroom_max'       => '4'                        },
        { 'bedroom_min'       => '1'                        },
        { 'sort'              => 'newest'                   },
        { 'keywords'          => 'garden'                   },
        { 'keywords_exclude'  => 'garden'                   },
    )
);

my @parameters_es_bilbao = (
    ## size is rarely set in the UK, so we use ES here
    apply { $_->{'country'} = 'es'; $_->{'place_name'} = 'bilbao'; } (
        { 'size_max'          => '1000'                     },
        { 'size_min'          => '10'                       },
    ),
);

my @parameters_de_wiesbaden = (
    ## rooms are used instead of bedrooms in Germany, so we use DE here
    apply { $_->{'country'} = 'de'; $_->{'place_name'} = 'wiesbaden'; } (
        { 'room_max'          => '1000'                     },
        { 'room_min'          => '10'                       },
    ),
);

my @parameters_uk_coordinates = (
    ## no placename set for these queries
    apply { $_->{'country'} = 'uk' } (
        {
            # 51.186654,0.738345,50.492894,-0.931577
            'south_west'      => '51.19,0.74',
            'north_east'      => '50.43,-0.93',
        },
        { 'centre_point'      => '51.47,-0.14',     },
        { 'radius'            => '51.47,-0.14,1km', },
    ),
);

my @parameters = (
    @parameters_uk_richmond,
    @parameters_es_bilbao,
    @parameters_de_wiesbaden,
    @parameters_uk_coordinates
);

foreach my $parameters (@parameters) {
    my $request  = $ns->request(%$parameters);
    my $response = $request->fetch;

#   uncomment for debugging:
#   note($request->url);

    my $query_string = join(
        ", ", 
        (
            apply { $_ = "$_: $parameters->{$_}" }
            sort keys %$parameters
        )
    );

    ok(
        $response && ($response->status_code == 200), 
        "$query_string - response"
    );
    ok(
        $response->count >= 1,
        "$query_string - results"
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
