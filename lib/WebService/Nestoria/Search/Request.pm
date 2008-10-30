use strict;
use warnings;

package WebService::Nestoria::Search::Request;

use WebService::Nestoria::Search::Response;
use JSON;
use LWP::UserAgent;
use HTTP::Request;
use URI;

=head1 NAME

WebService::Nestoria::Search::Request - Container object for a WebService::Nestoria::Search request.

This package is used by WebService::Nestoria::Search and a C<Request> object should never need to be explicitly created by the user.

=cut

sub new {
    my $class = shift;
    my $self = shift;

    return bless $self, $class;
}

=head1 Functions

=head2 uri

Returns a URI object representing the URL that will be fetched by this Request object.

=cut

sub uri {
    my $self = shift;

    unless ( $self->{_uri} ) {
        $self->{_uri} = new URI ($self->{ActionUrl}, 'http');
        $self->{_uri}->query_form( %{ $self->{Params} } );
    }
    return $self->{_uri};

}

=head2 url

Returns the URL that will be fetched by this request object as a string.

=cut

sub url {
    my $self = shift;
    return $self->uri->as_string;
}

=head2 fetch

Contact the Nestoria servers and return a WebService::Nestoria::Search::Response object.

If encoding is set to 'json', a WebService::Nestoria::Search::Result object is created for each listing. These can be accessed via the returned WebService::Nestoria::Search::Response object.

If the encoding is not 'json', the object returned will contain no WebService::Nestoria::Search::Result objects, and only the C<get_raw> function can be used effectively.

=cut

our $UA;
sub fetch {
    my $self = shift;

    $WebService::Nestoria::Search::RecentRequestUrl = $self->url;

    $UA ||= new LWP::UserAgent (agent => $self->{AppId});

    my $response = $UA->get($WebService::Nestoria::Search::RecentRequestUrl);
    sleep 2;

    unless ( $response ) {
        $@ = "couldn't make request";
        return;
    }

    my $raw = $response->content;

    if ($self->{Params}{encoding} eq 'json') {
        my $response_obj = from_json($raw);

        if ( ref $response_obj ) {
            return new WebService::Nestoria::Search::Response ($response_obj, $raw);
        }
        else {
            return;
        }
    }
    else {
        return new WebService::Nestoria::Search::Response ({}, $raw);
    }
}

=head1 Copyright

Copyright (C) 2006 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=cut

1;
