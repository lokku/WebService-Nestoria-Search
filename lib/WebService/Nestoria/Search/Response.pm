use strict;
use warnings;

package WebService::Nestoria::Search::Response;
{
  $WebService::Nestoria::Search::Response::VERSION = '1.021005';
}

use WebService::Nestoria::Search::Result;
use Carp;
use URI;

=head1 NAME

WebService::Nestoria::Search::Response - Container object for the result set of a query to the Nestoria Search API.

=head1 VERSION

version 1.021005

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

        $self->{results}[$i]
            = WebService::Nestoria::Search::Result->new($result);
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

Returns the HTTP status code of the response. 200 on success, various other numbers on errors.

=cut

sub status_code {
    my $self = shift;
    return $self->{data}{response}{status_code};
}

=head2 application_response_code

Returns the application response code, which is much more useful than the status_code for determining the correctness of the response.

Numbers starting 1xx are successes

Numbers starting 2xx are location errors

Numbers starting 5xx are internal server errors

Numbers starting 9xx are invalid request errors

For more information read the Nestoria API documentation: http://www.nestoria.co.uk/help/api-return-codes

=cut

sub application_response_code {
    my $self = shift;
    return $self->{data}{response}{application_response_code};
}

=head2 application_response_text

Returns the text description of the application response code. For example if the application response code is 100, the text is "one unambiguous location".

=cut

sub application_response_text {
    my $self = shift;
    return $self->{data}{response}{application_response_text};
}

=head2 is_success

Uses the status_code and application_response_code, and returns true if the request was a success and false otherwise. Concept stolen straight from LWP::UserAgent.

    if ($response->is_success) {
        foreach my $result ($response->results) {
            # do stuff...
        }
    }
    else {
        die $response->application_response_text;
    }

=cut

sub is_success {
    my $self = shift;
    return ($self->status_code == 200)
        && ($self->application_response_code =~ m/^1/);
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

=head2 nestoria_site_uri

Returns a URI object representing the URL for the Nestoria results page for the request.

=cut

sub nestoria_site_uri {
    my $self = shift;

    if ($self->{data}{response}{link_to_url}) {
        return URI->new($self->{data}{response}{link_to_url});
    }
    else {
        carp "No 'link_to_url' found in the response";
    }

    return;
}

=head2 nestoria_site_url

Returns a URL for the Nestoria results page for the request.

=cut

sub nestoria_site_url {
    my $self = shift;
    return $self->nestoria_site_uri->as_string;
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

    while ( $listing = $response->next_result ) {
        # do something;
    }

=cut

sub next_result {
    my $self = shift;

    if ( $self->{next_iterator} < @{$self->{results}} ) {
        return $self->{results}[$self->{next_iterator}++];
    }
    else {
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

Copyright (C) 2009 Lokku Ltd.

=head1 Author

Alex Balhatchet (alex@lokku.com)

Patches supplied by Yoav Felberbaum and Alistair Francis.

=cut

1;
