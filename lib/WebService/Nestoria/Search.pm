use strict;
use warnings;

package WebService::Nestoria::Search;

our $VERSION = 0.07;

use Carp;
use WebService::Nestoria::Search::Request;

=head1 NAME

WebService::Nestoria::Search - Perl interface to the Nestoria Search public API.

=head1 SYNOPSIS

WebService::Nestoria::Search provides a Perl interface to the public API of 
Nestoria a vertical search engine for property listings. Nestoria currently 
has listings for the UK and Spain, which can be accessed via the world-wide 
web at www.nestoria.co.uk and www.nestoria.es

use WebService::Nestoria::Search;

my @listings = WebService::Nestoria::Search->results(
    place_name          => 'soho',
    listing_type        => 'let',
    property_type       => 'flat',
    price_max           => '500',
    number_of_results   => '10',
    sort                => 'price_lowhigh',
    keywords            => 'garden,hot_tub,mews',
    keywords_exclude    => 'cottage,wood_floor'
    );

@listings is an array of WebService::Nestoria::Search::Result objects.

For more information about parameters and possible keywords visit
http://www.nestoria.co.uk/help/api-tech

=cut

##
## Configuration details for searching the Nestoria listings database
##
my %Config = (
    AppId                   => "WebService::Nestoria::Search $VERSION",
    MaxResults              =>  1000,

    ## keys indicate the universe of allowable arguments
    Defaults => {
        'action'              => 'search_listings',
        'version'             => '1.07',
        'encoding'            => 'json',
        'pretty'              => '0',     # pretty JSON results not needed
        'number_of_results'   => undef,   # defaults to 20 their end
        'place_name'          => undef,
        'south_west'          => undef,
        'north_east'          => undef,
        'centre_point'        => undef,
        'listing_type'        => undef,   # defaults to 'buy'
        'property_type'       => undef,   # defaults to 'all'
        'price_max'           => undef,   # defaults to 'max'
        'price_min'           => undef,   # defaults to 'min'
        'bedroom_max'         => undef,   # defaults to 'max'
        'bedroom_min'         => undef,   # defaults to 'min'
        'size_max'            => undef,   # only for Spain
        'size_min'            => undef,   # only for Spain
        'sort'                => undef,   # defaults to 'nestoria_rank'
        'keywords'            => undef,   # defualts to an empty list
        'keywords_exclude'    => undef,   # defaults to an empty list
    },
    
    Urls => {
        uk                  => 'http://api.nestoria.co.uk/api',
        es                  => 'http://api.nestoria.es/api',
    },
);

## filled in Search/Request.pm
our $RecentRequsetUrl;

my %GlobalDefaults = (
    Warnings                => 1,
    Country                 => 'uk'
);

##
## _carp_on_error helper function 'borrowed' from Yahoo::Search
##
sub _carp_on_error {
    $@ = shift;
    if ( $GlobalDefaults{Warnings} ) {
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
    my $val = shift || return 0;

    my ($lat, $long) = split (/,/, $val);

    return _validate_lat($lat) && _validate_long($long);
};

## latitude is a float between -180 and 180
sub _validate_lat {
    my $val = shift || return 0;

    if ( defined($val) && $val =~ /^[\+\-]?\d+\.?\d*$/ ) {
        return -180 <= $val && $val <= 180;
    }
    else {
        return 0;
    }
}

## longitude is a float between -90 and 90
sub _validate_long {
    my $val = shift || return 0;

    if ( defined($val) && $val =~ /^[\+\-]?\d+\.?\d*$/ ) {
        return -90 <= $val && $val <= 90;
    }
    else {
        return 0;
    }
}

my $validate_number_of_results = sub {
    my $val = shift || return 0;

    return ( $val =~ /^\d+$/ );
};

my $validate_listing_type = sub {
    my $val = shift || return 0;

    return grep { $val eq $_ } qw(let buy);
};

my $validate_property_type = sub {
    my $val = shift || return 0;

    return grep { $val eq $_ } qw(all house flat);
};

my $validate_max = sub {
    my $val = shift || return 0;

    return $val eq 'max' || $val =~ /^\d+$/;
};

my $validate_min = sub {
    my $val = shift || return 0;

    return $val eq 'min' || $val =~ /^\d+$/;
};

my $validate_sort = sub {
    my $val = shift || return 0;

    return grep { $val eq $_ } qw(bedroom_lowhigh bedroom_highlow
                                  price_lowhigh price_highlow);
}; 

my $validate_version = sub {
    my $val = shift || return 0;

    return $val eq '1.07';
};

my $validate_action = sub {
    my $val = shift || return 0;

    return grep { $val eq $_ } qw(search_listings echo);
};

my $validate_encoding = sub {
    my $val = shift || return 0;

    return grep { $val eq $_ } qw(json xml);
};

my $validate_pretty = sub {
    my $val = shift;

    return defined $val && ($val == 0 || $val == 1);
};

## Mapping from arg name to validation sub
my %ValidateRoutine = (
    'place_name'          => $validate_allow_all,
    'south_west'          => $validate_lat_long,
    'north_east'          => $validate_lat_long,
    'centre_point'        => $validate_lat_long,
    'number_of_results'   => $validate_number_of_results,
    'listing_type'        => $validate_listing_type,
    'property_type'       => $validate_property_type,
    'price_max'           => $validate_max,
    'price_min'           => $validate_min,
    'bedroom_max'         => $validate_max,
    'bedroom_min'         => $validate_min,
    'size_max'            => $validate_max,
    'size_min'            => $validate_min,
    'sort'                => $validate_sort,
    'keywords'            => $validate_allow_all,
    'keywords_exclude'    => $validate_allow_all,
    'version'             => $validate_version,
    'action'              => $validate_action,
    'encoding'            => $validate_encoding,
    'pretty'              => $validate_pretty,
); 

sub _validate {
    my $key = shift;
    my $val = shift;

    unless ( defined $key && defined $val ) {
        return "validation error";
    }

    if ( $key eq 'Warnings' ) {
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

Creates a WebService::Nestoria::Search object.
On error sets C<$@> and returns C<undef>.

If given 'request' arguments (eg. place_name, listing_type) these
become defaults for calls to Request.

    %args = ( Warnings => 0, listing_type => 'let' );
    $NS = WebService::Nestoria::Search->new( %args );

=cut

sub new {
    my $class = shift;
    my $self;

    if ( @_ % 2 != 0 ) {
        return _carp_on_error("wrong arg count to $class->new");
    }

    $self->{Defaults} = { @_ };

    if ( exists $self->{Defaults}{Warnings} ) {
        $GlobalDefaults{Warnings} = $self->{Defaults}{Warnings};
        delete $self->{Defaults}{Warnings};
    }

    if ( exists $self->{Defaults}{Country} ) {
        unless ( exists $Config{Urls}->{$self->{Defaults}{Country}} ) {
                _carp_on_error("Invalid country");
        }
        $GlobalDefaults{Country} = $self->{Defaults}{Country};
        delete $self->{Defaults}{Country};
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

Creates a WebService::Nestoria::Search::Request object. 
On error sets C<$@> and returns C<undef>

    $request = WebService::Nestoria::Search->request( %args );

=cut

sub request {
    my $self = shift;

    if ( @_ % 2 != 0 ) {
        return _carp_on_error("wrong arg count for request");
    }
    
    my %args = @_;

    unless ( ref $self ) {
        $self = new $self;
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
    $params{ActionUrl} = $Config{Urls}->{$GlobalDefaults{Country}};
    $params{AppId}     = $Config{AppId};
    $params{Params}    = \%args;

    if (defined $args{number_of_results} && $args{number_of_results} > $Config{MaxResults}) {
        return _carp_on_error("number_of_results $args{number_of_results} too large, maximum is $Config{MaxResults}");
    }

    return new WebService::Nestoria::Search::Request (\%params);
}

=head2 query

Creates an implicit Request object and returns the resulting Response. On 
error, sets C<$@> and returns C<undef>.

    $response = WebService::Nestoria::Search->query( %args );

=cut

sub query {
    my $self = shift;
    
    unless ( ref $self ) {
        $self = new $self;
    }

    if ( my $request = $self->request(@_) ) {
        return $request->fetch();
    }
    else {
        return;
    }
}

=head2 results

Creates an implicit C<Request> object, then an implicit C<Response> object,
and returns an array of C<Result> objects. On error, sets C<$@> and returns
C<undef>.

    @results = WebService::Nestoria::Search->results( %args );

=cut

sub results {
    my $self = shift;

    unless ( ref $self ) {
        $self = new $self;
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


=head1 AutoCarp

AutoCarp is true by default and means that errors are output to STDERR as 
well as being returned via $@. This can be turned off by adding

    AutoCarp => 0

to the parameters to WebService::Nestoria::Search::new()

TODO: People should be able to 'AutoCarp => 0' on the use line

=head1 Country

Country is an optional parameter which is currently useless because the only
correct value to give it is 'uk', to which it already defaults.

It affects the URL which is used for fetching results. For example 'uk' gives
http://api.nestoria.co.uk/api, in the future 'fr' might give ..nestoria.fr..

=head1 Copyright

Copyright (C) 2006 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=head1 Acknowledgements

A lot of the ideas (and yes, very occasionally entire functions) for these
modules were borrowed from Jeffrey Friedl's Yahoo::Search.

=cut

1;
