use strict;
use warnings;

package WebService::Nestoria::Search::Response;

use WebService::Nestoria::Search::Result;

=head1 NAME

WebService::Nestoria::Search::Response - Container object for the result set 
of a query to the Nestoria Search API.

This package is used by WebService::Nestoria::Search and a C<Result> object 
should never need to be explicitly created by the user.

=cut

sub new {
    my $class = shift;
    my $self;

    $self->{data} = shift;
    $self->{json} = shift;
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

=head2 status_code

Returns the status code of the response. 200 on success, various other numbers
on errors.

=cut

sub status_code {
    my $self = shift;
    return $self->{data}{response}{status_code};
}

=head2 get_json

Returns the unchanged JSON (JavaScript Object Notation) returned by the
Nestoria API

=cut

sub get_json {
    my $self = shift;
    return $self->{json};
}

=head2 get_hashref

Returns a reference to a hash that contains exactly what the response from
the Nestoria API gave, converted from JSON to a hashref with JSON::jsonToObj()

=cut

sub get_hashref {
    my $self = shift;
    return $self->{data};
}

=head2 count

Returns the number of listings found. These can be accessed as C<Result>
objects by calling the methods mentioned below.

=cut

sub count {
    my $self = shift;
    return scalar @{$self->{results}};
}

=head2 results

Returns an array of listings (C<Result> objects) containing all
the information about the listings returned by the Nestoria API.

=cut

sub results {
    my $self = shift;
    return @{$self->{results}};
}

=head2 next_result

Returns the next C<Result> object to be fetched. When out of listings
returns C<undef>, making it suitable for use in while loops.

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

Copyright (C) 2006 Lokku Ltd.

=head1 Author

Alex Balhatchet (kaoru@slackwise.net)

=cut

1;
