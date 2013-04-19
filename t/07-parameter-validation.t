use strict;
use warnings;

use Test::More;
use Test::Warn;
use WebService::Nestoria::Search Warnings => 1;

##########################################################################
## plan
##
plan tests => 95;
my $ns;

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
        'good' => [ qw(uk es it de fr br in) ],
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
        'good' => [ 'house', 'flat', 'all', 'land' ],
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
