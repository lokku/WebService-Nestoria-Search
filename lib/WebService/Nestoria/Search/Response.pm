use strict;
use warnings;

package WebService::Nestoria::Search::Response;

use WebService::Nestoria::Search::Result;

=head1 NAME

WebService::Nestoria::Search::Response - Container object for the result set of a query to the Nestoria Search API.

This package is used by WebService::Nestoria::Search and a WebService::Nestoria::Search::Response object should never need to be explicitly created by the user.

=cut

sub new {
    my $class = shift;
    my $self;

    $self->{data} = shift;
    $self->{raw} = shift;
    $self->{next_iterator} = 0;

    my $listings = $self->{data}{response}{listings} || [];

    $self->{results} = [];
    for( my $i = 0; $i < @$listings; $i++ ) {
        my $result = {};
        $result->{listing} = $listings->[$i];
        $result->{ordinal} = $i;
        $result->{response} = $self->{data};

        $self->{results}[$i] = new WebService::Nestoria::Search::Result ($result);
    }

    return bless $self, $class;

}

=head1 Functions

=head2 get_raw

Returns the raw data returned by the Nestoria API. By default this will be JSON (JavaScript Object Notation.) C<get_json> and C<get_xml> are aliases to C<get_raw>.

=cut

sub get_raw {
    my $self = shift;
    return $self->{raw};
}

sub get_json {
    my $self = shift;
    return $self->get_raw;
}

sub get_xml {
    my $self = shift;
    return $self->get_raw;
}

=head2 status_code

Returns the status code of the response. 200 on success, various other numbers on errors.

=cut

sub status_code {
    my $self = shift;
    return $self->{data}{response}{status_code};
}



=head2 get_hashref

Returns a reference to a hash that contains exactly what the response from the Nestoria API gave, converted from JSON into a hashref with JSON::from_json()

=cut

sub get_hashref {
    my $self = shift;
    return $self->{data};
}

=head2 count

Returns the number of listings found.

=cut

sub count {
    my $self = shift;
    return scalar @{$self->{results}};
}

=head2 attribution

Returns a reference to a hash that contains the 'attribution' data returend by the server. Allows users to link back to Nestoria.

=cut

sub attribution {
    my $self = shift;
    return $self->{data}{response}{attribution};
}

=head2 attribution_html

Returns the attribution formatted in HTML for ease of use on websites.

=cut

sub attribution_html {
    my $self = shift;
    return sprintf '<a href="%s"><img height="%s" width="%s" src="%s">',
           $self->{data}{response}{attribution}{link_to_img},
           $self->{data}{response}{attribution}{img_height},
           $self->{data}{response}{attribution}{img_width},
           $self->{data}{response}{attribution}{img_url};
}

=head2 attribution_xhtml

Returns the attribution formatted in XHTML for ease of use on websites.

=cut

sub attribution_xhtml {
    my $self = shift;
    return sprintf '<a href="%s"><img src="%s" style="height: %spx; width: %spx;" />',
           $self->{data}{response}{attribution}{link_to_img},
           $self->{data}{response}{attribution}{img_url},
           $self->{data}{response}{attribution}{img_height},
           $self->{data}{response}{attribution}{img_width};
}

=head2 results

Returns an array of WebService::Nestoria::Search::Result objects, each containing data about a single listing returned by the Nestoria API.

=cut

sub results {
    my $self = shift;
    return @{$self->{results}};
}

=head2 next_result

Returns the next WebService::Nestoria::Search::Result object to be fetched. When out of listings returns C<undef>, making it suitable for use in while loops.

    while ( $listing = $result->next_result ) {
        # do something;
    }

=cut

sub next_result {
    my $self = shift;

    if ( $self->{next_iterator} < @{$self->{results}} ) {
        return $self->{results}[$self->{next_iterator}++];
    }
    else {
        $self->{next_iterator} = 0;
        return;
    }
}

=head2 reset

Resets the counter used for next_result.

=cut

sub reset {
    my $self = shift;

    $self->{next_iterator} = 0;
}

=head1 Copyright

Copyright (C) 2008 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru at slackwise dot net), Yoav Felberbaum (perl at mrdini dot com), Alistair Francis (cpan at alizta dot com).

=cut

1;
