use strict;
use warnings;

package WebService::Nestoria::Search;
{
  $WebService::Nestoria::Search::VERSION = '1.021003';
}

use Carp;
use URI;
use WebService::Nestoria::Search::Request;
use WebService::Nestoria::Search::MetadataResponse;

=head1 NAME

WebService::Nestoria::Search - Perl interface to the Nestoria Search public API.

=head1 VERSION

version 1.021003

=head1 SYNOPSIS

WebService::Nestoria::Search provides a Perl interface to the public API of Nestoria, a vertical search engine for property listings.

WebService::Nestoria::Search is currently written to be used with v1.18 of the Nestoria API.

Functions and documentation are split over WebService::Nestoria::Search, WebService::Nestoria::Search::Request, WebService::Nestoria::Search::Response and WeebService::Nestoria::Search::Result. However you need only ever use WebService::Nestoria::Search, and the others will be used as necessary.

A Request object stores the parameters of the request, a Response object stores the data retrieved from the API (in JSON and Perl hashref formats), and a Result represents an individual listing.

=head2 Parameters

The possible parameters and their defaults are as follows:

    country             (default: 'uk')
    warnings            (default: 1)
    action              (default: 'search_listings')
    version
    encoding            (default: 'json')
    pretty              (default: 0)
    number_of_results
    page
    place_name
    south_west
    north_east
    centre_point
    radius
    listing_type
    property_type
    price_max
    price_min
    bedroom_max
    bedroom_min
    bathroom_max
    bathroom_min
    room_max
    room_min
    size_max
    size_min
    sort
    keywords
    keywords_exclude

If parameters are passed to C<new> they are used as the defaults for all calls to the API. Otherwise they can be passed to the querying functions (eg. C<query>) as per-search parameters.

You should never have to set the 'action' parameter yourself, it is implied by the method you choose to use to run the query.

=head2 Simple Example

    use WebService::Nestoria::Search;

    my $NS = WebService::Nestoria::Search->new(
        place_name          => 'soho',
        listing_type        => 'rent',
        property_type       => 'flat',
        price_max           => '500',
        number_of_results   => '10',
    );

    my @results = $NS->results(
        keywords            => 'garden,hot_tub,mews',
        keywords_exclude    => 'cottage,wood_floor'
    );

    foreach my $result (@results) {
        print $result->get_title, "\n";
    }

C<@listings> is an array of WebService::Nestoria::Search::Result objects.

=head2 Using the Request object

    my $request = $NS->request;

    print "Will fetch: ", $request->url, "\n";

    my $response = $request->fetch;

=head2 Using the Response object

    my $response = $NS->query;

    if ($response->status_code == 200) {
        print "Success! Got ", $response->count, " results\n";
    }

    print "Raw JSON\n", $response->get_json, "\n";

    while (my $result = $response->next_result) {
        print $result->get_thumb_url, "\n";
    }

=head2 Using a bounding box

    my @bound_results = $ns->results('south_west' => '51.473685,-0.148315', 'north_east' => '50.473685,-0.248315');

    foreach my $result  (@bound_results) {
        print $result->get_title, "\n";
    }

=cut

##
## Configuration details for searching the Nestoria listings database
##
my %Config = (
    'AppId'                   => "WebService::Nestoria::Search $WebService::Nestoria::Search::VERSION",
    'MaxResults'              => '1000',

    ## keys indicate the universe of allowable arguments
    'Defaults' => {
        'action'              => 'search_listings',
        'version'             => undef,   # defaults to the latest version
        'encoding'            => 'json',
        'pretty'              => '0',     # pretty JSON results not needed
        'number_of_results'   => undef,   # defaults to 20 their end
        'page'                => undef,   # defautls to 1 on their end
        'place_name'          => undef,
        'south_west'          => undef,
        'north_east'          => undef,
        'centre_point'        => undef,
        'radius'              => undef,
        'listing_type'        => undef,   # defaults to 'buy'
        'property_type'       => undef,   # defaults to 'all'
        'price_max'           => undef,   # defaults to 'max'
        'price_min'           => undef,   # defaults to 'min'
        'bedroom_max'         => undef,   # defaults to 'max'
        'bedroom_min'         => undef,   # defaults to 'min'
        'bathroom_max'        => undef,   # defaults to 'max'
        'bathroom_min'        => undef,   # defaults to 'min'
        'room_max'            => undef,   # defaults to 'max'
        'room_min'            => undef,   # defaults to 'min'
        'size_max'            => undef,   # defaults to 'max'
        'size_min'            => undef,   # defaults to 'min'
        'sort'                => undef,   # defaults to 'nestoria_rank'
        'keywords'            => undef,   # defaults to an empty list
        'keywords_exclude'    => undef,   # defaults to an empty list
        'callback'            => undef,
    },

    'Urls' => {
        'uk'                  => 'http://api.nestoria.co.uk/api',
        'es'                  => 'http://api.nestoria.es/api',
        'de'                  => 'http://api.nestoria.de/api',
        'it'                  => 'http://api.nestoria.it/api',
        'fr'                  => 'http://api.nestoria.fr/api',
        'au'                  => 'http://api.nestoria.com.au/api',
        'br'                  => 'http://api.nestoria.com.br/api',
        'in'                  => 'http://api.nestoria.in/api',
    },
);

## filled in Search/Request.pm
our $RecentRequestUrl;

my %GlobalDefaults = (
    'warnings'                => '1',
    'country'                 => 'uk'
);


##
## import function allows 'Warnings' to be specified on the use line
##

sub import {
    my $class = shift;
    my %args = @_;

    if (defined $args{'Warnings'}) {
        $args{'warnings'} = $args{'Warnings'};
    }

    if (defined $args{'warnings'}) {
        $GlobalDefaults{'warnings'} = $args{'warnings'};
    }
}

##
## _carp_on_error helper function borrowed from Yahoo::Search
##
sub _carp_on_error {
    $@ = shift;
    if ( $GlobalDefaults{warnings} ) {
        carp $@;
    }

    return;
}

##
## subs for validating arguments
##

my $validate_allow_all = sub {
    ## allow any defined input
    return defined shift;
};

my $validate_lat_long = sub {
    my $val = shift;
    my ($lat, $long) = split (/,/, $val);
    return _validate_lat($lat) && _validate_long($long);
};

my $validate_radius = sub {
    my $val = shift;
    my ($lat,$long,$radius) = split(/,/, $val);
    return _validate_lat($lat) && _validate_long($long) &&
           ($radius =~ m/^\d+(km|mi)$/);
};

## latitude is a float between -180 and 180
sub _validate_lat {
    my $val = shift;
    if ( defined($val) && $val =~ /^[\+\-]?\d+\.?\d*$/ ) {
        return -180 <= $val && $val <= 180;
    }
    else {
        return;
    }
}

## longitude is a float between -90 and 90
sub _validate_long {
    my $val = shift;
    if ( defined($val) && $val =~ /^[\+\-]?\d+\.?\d*$/ ) {
        return -90 <= $val && $val <= 90;
    }
    else {
        return;
    }
}

my $validate_positive_integer = sub {
    my $val = shift;
    return ( $val =~ /^\d+$/ && $val > 0 );
};

my $validate_listing_type = sub {
    my $val = shift;
    return grep { $val eq $_ } qw(buy rent share);
};

my $validate_property_type = sub {
    my $val = shift;
    return grep { $val eq $_ } qw(all house flat land);
};

my $validate_max = sub {
    my $val = shift;
    return $val eq 'max' || $val =~ /^\d+$/;
};

my $validate_min = sub {
    my $val = shift;
    return $val eq 'min' || $val =~ /^\d+$/;
};

my $validate_sort = sub {
    my $val = shift;
    return grep { $val eq $_ } qw(bedroom_lowhigh bedroom_highlow
                                  price_lowhigh price_highlow
                                  newest oldest);
};

my $validate_version = sub {
    my $val = shift;
    return $val =~ m/^[\d.]+$/;
};

my $validate_action = sub {
    my $val = shift;
    return grep { $val eq $_ } qw(search_listings echo keywords metadata);
};

my $validate_encoding = sub {
    my $val = shift;
    return grep { $val eq $_ } qw(json xml);
};

my $validate_pretty = sub {
    my $val = shift;
    return $val == 0 || $val == 1;
};

my $validate_country = sub {
    my $val = shift;
    return $Config{'Urls'}{$val};
};

## Mapping from arg name to validation sub
my %ValidateRoutine = (
    'country'             => $validate_country,
    'place_name'          => $validate_allow_all,
    'south_west'          => $validate_lat_long,
    'north_east'          => $validate_lat_long,
    'centre_point'        => $validate_lat_long,
    'radius'              => $validate_radius,
    'number_of_results'   => $validate_positive_integer,
    'page'                => $validate_positive_integer,
    'listing_type'        => $validate_listing_type,
    'property_type'       => $validate_property_type,
    'price_max'           => $validate_max,
    'price_min'           => $validate_min,
    'bedroom_max'         => $validate_max,
    'bedroom_min'         => $validate_min,
    'bathroom_max'        => $validate_max,
    'bathroom_min'        => $validate_min,
    'room_max'            => $validate_max,
    'room_min'            => $validate_min,
    'size_max'            => $validate_max,
    'size_min'            => $validate_min,
    'sort'                => $validate_sort,
    'keywords'            => $validate_allow_all,
    'keywords_exclude'    => $validate_allow_all,
    'version'             => $validate_version,
    'action'              => $validate_action,
    'encoding'            => $validate_encoding,
    'pretty'              => $validate_pretty,
    'has_photo'           => $validate_allow_all,
    'guid'                => $validate_allow_all,
);

sub _validate {
    my $key = shift;
    my $val = shift;

    unless ( defined $key && defined $val ) {
        return "validation error";
    }

    if ( $key eq 'warnings' ) {
        return;
    }

    unless ( $ValidateRoutine{$key} ) {
        return "unknown argument '$key'";
    }

    if ( $ValidateRoutine{$key}->($val) ) {
        return;
    }
    else {
        return "invalid value '$val' for '$key' argument";
    }
}

=head1 FUNCTIONS

=head2 new

Creates a WebService::Nestoria::Search object.  On error sets C<$@> and returns C<undef>.

If given 'request' parameters (eg. place_name, listing_type) these become defaults for all calls to the API.

    my %args = (warnings => 0, listing_type => 'rent', place_name => 'soho');
    my $NS = WebService::Nestoria::Search->new(%args);

=cut

sub new {
    my $class = shift;
    my $self;

    if ( @_ % 2 != 0 ) {
        return _carp_on_error("wrong arg count to $class->new");
    }

    $self->{Defaults} = { @_ };

    foreach my $key (keys %{ $self->{Defaults} }) {
        if ($key =~ m/[A-Z]/) {
            my $newkey = lc $key;
            $self->{Defaults}{$newkey} = $self->{Defaults}{$key};
            delete $self->{Defaults}{$key};
        }
    }

    if ( exists $self->{Defaults}{warnings} ) {
        $GlobalDefaults{warnings} = $self->{Defaults}{warnings};
        delete $self->{Defaults}{warnings};
    }

    if ( exists $self->{Defaults}{country} ) {
        unless ( exists $Config{Urls}->{$self->{Defaults}{country}} ) {
                _carp_on_error("Invalid country");
        }
        $GlobalDefaults{country} = $self->{Defaults}{country};
        delete $self->{Defaults}{country};
    }

    my $defaults = $self->{Defaults};
    foreach my $key (keys %$defaults) {
        my $error = _validate($key, $self->{Defaults}{$key});
        if ( $error ) {
            return _carp_on_error("$error, in call to $class->new");
        }
    }

    foreach my $key (keys %GlobalDefaults) {
        $self->{$key} ||= $GlobalDefaults{$key};
    }

    return bless $self, $class;
}

=head2 request

Creates a WebService::Nestoria::Search::Request object. On error sets C<$@> and returns C<undef>

    my $request = WebService::Nestoria::Search->request(%args);

=cut

sub request {
    my $self = shift;

    if ( @_ % 2 != 0 ) {
        return _carp_on_error("wrong arg count for request");
    }

    my %args = @_;

    unless ( ref $self ) {
        $self = $self->new;
    }

    foreach my $key ( keys %GlobalDefaults ) {
        $args{$key} ||= $GlobalDefaults{$key};
    }

    foreach my $key ( keys %{ $self->{Defaults} } ) {
        next if grep { $key eq $_ } keys %GlobalDefaults;
        $args{$key} ||= $self->{Defaults}{$key};
    }

    foreach my $key ( keys %{ $Config{Defaults} } ) {
        if ( defined $Config{Defaults}{$key} ) {
            $args{$key} ||= $Config{Defaults}{$key};
        }
    }

    foreach my $key ( keys %args ) {
        my $error = _validate($key, $args{$key});
        if ( $error ) {
            return _carp_on_error($error);
        }
    }

    my %params;
    $params{ActionUrl} = $Config{Urls}->{$args{country}};
    $params{AppId}     = $Config{AppId};
    $params{Params}    = \%args;

    if (defined $args{number_of_results} && $args{number_of_results} > $Config{MaxResults}) {
        return _carp_on_error("number_of_results $args{number_of_results} too large, maximum is $Config{MaxResults}");
    }

    return WebService::Nestoria::Search::Request->new(\%params);
}

=head2 query

Queries the API and returns a WebService::Nestoria::Search::Response object. On error, sets C<$@> and returns C<undef>.

    my $response = $NS->query(%args);

This is a shortcut for

    my $request = $NS->request(%args);
    my $response = $request->fetch;

=cut

sub query {
    my $self = shift;

    unless ( ref $self ) {
        $self = $self->new;
    }

    if ( my $request = $self->request(@_) ) {
        return $request->fetch();
    }
    else {
        return;
    }
}

=head2 results

Returns an array of WebService::Nestoria::Search::Result objects. On error, sets C<$@> and returns C<undef>.

    my @results = $NS->results(%args);

This is a shortcut for

    my $request = $NS->request(%args);
    my $response = $request->fetch;
    my @results = $response->results;

=cut

sub results {
    my $self = shift;

    unless ( ref $self ) {
        $self = $self->new;
    }

    my $response = $self->query(@_);

    unless ( $response ) {
        return;
    }

    return $response->results();
}

=head2 test_connection

Uses the API feature 'action=echo' to test the connection.

Returns 1 if the connection is successful and 0 otherwise.

    unless ($NS->test_connection) {
        die "Cannot establish connection with Nestoria API\n";
    }

=cut

sub test_connection {
    my $self = shift;

    my %params = ( action => 'echo' );

    my $response = $self->query(%params);
    if ( defined $response && $response->status_code == 200 ) {
        return 1;
    }
    else {
        return 0;
    }
}

=head2 keywords

Uses the API feature 'action=keywords' to return a list of valid keywords. A current list of keywords can be found at the below URL, but do not hardcode the list of keywords in your code as it is occasionally subject to change.

    my @keywords = $NS->keywords;

Taken from B<http://www.nestoria.co.uk/help/api-tech>.

=cut

sub keywords {
    my $self = shift;

    my %params = ( action => 'keywords' );

    my $response = $self->query(%params);

    my $data = $response->get_hashref;

    return ( split(/,\s+/, $response->get_hashref->{'response'}{'keywords'}) );
}

=head2 metadata

Uses the API feature 'action=metadata' to return metadata about the listings. Returns a WebService::Nestoria::Search::MetadataResponse object with average house, flat and property prices aggregated monthly and quarterly.

    my $metadata_response = WebService::Nestoria::Search->metadata(%args);

=cut

sub metadata {
    my $self = shift;

    unless ( ref $self ) {
        $self = $self->new;
    }

    my %params = ( action => 'metadata' );

    my $response = $self->query(%params, @_);

    return WebService::Nestoria::Search::MetadataResponse->new($response->get_hashref);
}

=head2 last_request_uri

Returns a URI object representing the URL that was last fetched by
WebService::Nestoria::Search::Request.

=cut

sub last_request_uri {
    return URI->new($RecentRequestUrl);
}

=head2 last_request_url

Returns the URL that was last fetched by WebService::Nestoria::Search::Request.

=cut

sub last_request_url {
    return $RecentRequestUrl;
}

=head1 Warnings

Warnings is true by default, and means that errors are output to STDERR as well as being returned via $@. This can be turned off either on the C<use> line

    use WebService::Nestoria::Search Warnings => 0;

or when calling C<new>

    my $NS = WebService::Nestoria::Search->new(Warnings => 0);

=head1 Country

Country is an optional parameter which defaults to 'uk'. It affects the URL which is used for fetching results.

Currently the available countries are:

=over 4

=item * uk - United Kingdom

=item * es - Spain

=item * it - Italy

=item * de - Germany

=item * fr - France

=item * br - Brazil

=item * in - India

=back

=head1 Non-OO

It is possible to run WebService::Nestoria::Search functions without creating an object. However, no functions are exported (by default or otherwise) so the full name must be used.

    my @results = WebService::Nestoria::Search->results(%args);

=head1 Copyright

Copyright (C) 2009 Lokku Ltd.

=head1 Author

Alex Balhatchet (alex@lokku.com)

Patches supplied by Yoav Felberbaum and Alistair Francis.

=head1 Acknowledgements

A lot of the ideas (and yes, very occasionally entire functions) for these modules were borrowed from Jeffrey Friedl's Yahoo::Search.

This module would not exist without the public API available from Nestoria (B<http://www.nestoria.co.uk/help/api>.)

=cut

1;
