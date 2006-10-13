use strict;
use warnings;

package WebService::Nestoria::Search::Result;

=head1 NAME

WebService::Nestoria::Search::Result - Container object for a 
WebService::Nestoria::Search result.

Contains all the information received about a single property listing and
many functions for outputting the information.

This package is used by WebService::Nestoria::Search and a C<Result> object 
should never need to be explicitly created by the user.

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
    get_lister_name
    get_lister_url
    get_price
    get_price_currency
    get_price_formatted
    get_title
    get_summary
    get_bedroom_number
    get_thumb_url
    get_thumb_height
    get_thumb_width

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

=head2 get_hashref

Returns a hashref containing the details of the listing with keys exactly as
the list above.

=cut

sub get_hashref {
    my $self = shift;
    return $self->{data}{listing};
}

=head1 Copyright

Copyright (C) 2006 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=cut

1;
