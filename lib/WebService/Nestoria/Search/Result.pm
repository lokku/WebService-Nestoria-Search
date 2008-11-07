use strict;
use warnings;

package WebService::Nestoria::Search::Result;

=head1 NAME

WebService::Nestoria::Search::Result - Container object for a WebService::Nestoria::Search result.

Contains all the information received about a single property listing and many functions for outputting the information.

This package is used by WebService::Nestoria::Search and a Result object should never need to be explicitly created by the user.

=cut

sub new {
    my $class = shift;
    my $self;

    $self->{data} = shift;

    return bless $self, $class;
}

=head1 Functions

=head2 get_*

The get_* functions each return one attribute about the listing. They are
as follows:

    get_latitude
    get_longitude
    get_listing_type
    get_property_type
    get_datasource_name
    get_lister_name
    get_lister_url
    get_price
    get_price_type
    get_price_currency
    get_price_formatted
    get_title
    get_summary
    get_bedroom_number
    get_thumb_url
    get_thumb_height
    get_thumb_width
    get_keywords
    get_guid

=cut

sub get_latitude {
    my $self = shift;
    return $self->{data}{listing}{latitude};
}

sub get_longitude {
    my $self = shift;
    return $self->{data}{listing}{longitude};
}

sub get_listing_type {
    my $self = shift;
    return $self->{data}{listing}{listing_type};
}

sub get_property_type {
    my $self = shift;
    return $self->{data}{listing}{property_type};
}

sub get_datasource_name {
    my $self = shift;
    return $self->{data}{listing}{datasource_name};
}

sub get_lister_name {
    my $self = shift;
    return $self->{data}{listing}{lister_name};
}

sub get_lister_url {
    my $self = shift;
    return $self->{data}{listing}{lister_url};
}

sub get_price {
    my $self = shift;
    return $self->{data}{listing}{price};
}

sub get_price_type {
    my $self = shift;
    return $self->{data}{listing}{price_type};
}

sub get_price_currency {
    my $self = shift;
    return $self->{data}{listing}{price_currency};
}

sub get_price_formatted {
    my $self = shift;
    return $self->{data}{listing}{price_formatted};
}

sub get_title {
    my $self = shift;
    return $self->{data}{listing}{title};
}

sub get_summary {
    my $self = shift;
    return $self->{data}{listing}{summary};
}

sub get_bedroom_number {
    my $self = shift;
    return $self->{data}{listing}{bedroom_number};
}

sub get_thumb_url {
    my $self = shift;
    return $self->{data}{listing}{thumb_url};
}

sub get_thumb_height {
    my $self = shift;
    return $self->{data}{listing}{thumb_height};
}

sub get_thumb_width {
    my $self = shift;
    return $self->{data}{listing}{thumb_width};
}

sub get_keywords {
    my $self = shift;
    return $self->{data}{listing}{keywords};
}

sub get_guid {
    my $self = shift;
    return $self->{data}{listing}{guid};
}

=head2 get_hashref

Returns a hashref containing the details of the listing with keys exactly as the list above. For example:

    use Data::Dumper;
    print Dumper($result->hashref);

    $VAR1= {
        'price_currency' => 'GBP',
        'bathroom_number' => '2',
        'price_formatted' => '459,950 GBP',
        'listing_type' => 'buy',
        'keywords' => 'Garden, Loft, Cellar, Reception',
        'summary' => 'In need of complete refurbishment is this four bedroom family home located...',
        'latitude' => '51.4508',
        'lister_url' => 'http://rd.nestoria.co.uk/rd?l=api-sr-title-1&url=...',
        'property_type' => 'house',
        'price_type' => 'fixed',
        'longitude' => '-0.129012',
        'thumb_width' => '60',
        'lister_name' => 'KF&H',
        'thumb_url' => 'http://limg.nestoria.co.uk/f/b/fb67e2b0d76350f7ebcf8fa6488b2ec4.jpg',
        'title' => 'Thornbury Road, Brixton',
        'price' => '459950',
        'bedroom_number' => '4',
        'thumb_height' => '60',
        'datasource_name' => 'PropertyFinder'
    };

=cut

sub get_hashref {
    my $self = shift;
    return $self->{data}{listing};
}

=head1 Copyright

Copyright (C) 2008 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru at slackwise dot net), Yoav Felberbaum (perl at mrdini dot com)

=cut

1;
