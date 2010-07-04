use strict;
use warnings;

package WebService::Nestoria::Search::MetadataResponse;

=head1 NAME

WebService::Nestoria::Search::MetadataResponse - Container object for the result of a metadata query to the Nestoria Search API.

This package is used by WebService::Nestoria::Search and a WebService::Nestoria::Search::MetadataResponse object should never need to be explicitly created by the user.

=cut

sub new {
    my $class = shift;
    my $self;

    $self->{data} = shift;

    my $metadata = $self->{data}{response}{metadata};
    foreach my $stat (@$metadata) {
        my $name = $stat->{metadata_name};
        $self->{metadata}{$name} = $stat;
    }

    return bless $self, $class;
}

=head1 Functions

=head2 get_hashref

Returns a reference to a hash that contains exactly what the response from the Nestoria API gave, converted from JSON into a hashref with JSON::from_json()

=cut

sub get_hashref {
    my $self = shift;
    return $self->{data};
}

=head2 get_metadata

Returns a reference to a hash that maps metadata names to the statistics associated with it.

=cut

sub get_metadata {
    my $self = shift;
    return $self->{metadata};
}

=head2 get_average_price

Returns the average for properties which match the number of bedrooms, property type and listing type, for the given month.

    my %options = (
        # required
        listing_type => 'rent',
        range => 'monthly',             # 'monthly' ('quarterly' is deprecated, and has no data.)
        
        # optional depending on 'range'
        year => 2007,                   # 4 digit date
        month => 'January',             # eg. '1', 'Jan' or 'January'

        # optional
        num_beds => 3                   # integer
        per_sqm => 1,                   # price returned per square metre
    );
    my $average_price = $metadata->get_average_price(%options);

Rent prices are monthly. Prices for the UK are in GBP. Prices for Spain, Italy and Germany are in Euros. The earliest date available is October 2007.

If you leave out the year and month parameters it will take the most recent available.

=cut

sub get_average_price {
    my $self = shift;

    if ( @_ % 2 != 0 ) {
        warn "wrong arg count to get_average_price";
    }
    my %params = @_;

    foreach my $required ( qw(listing_type range) ) {
        if ( ! exists $params{$required} ) {
            warn "required paramter $required not given\n";
            return;
        }
    }

    my $metadata_name = $self->_get_metadata_name(%params);
    my $metadata_date = $self->_get_metadata_date($metadata_name, %params);

    if (defined $metadata_name && defined $metadata_date) {
        return $self->{'metadata'}{$metadata_name}{'data'}{$metadata_date}{'avg_price'};
    }
    else {
        return;
    }
}

sub _get_metadata_name {
    my $self = shift;
    my %params = @_;

    ## avg_5bed_property_buy_monthly_per_sqm

    my $name = "avg_";

    if ($params{'num_beds'}) {
        $name .= $params{'num_beds'} . "bed_";
    }

    $name .= "property_";

    $name .= $params{'listing_type'} . "_";

    $name .= $params{'range'};

    if ($params{'per_sqm'}) {
        $name .= "_per_sqm";
    }

    return $name;
}

my %short_months = (
    Jan => 1, Feb => 2, Mar => 3, Apr => 4,
    May => 5, Jun => 6, Jul => 7, Aug => 8,
    Sep => 9, Oct => 10, Nov => 11, Dec => 12
);

my %long_months = (
    January => 1, February => 2, March => 3, April => 4,
    May => 5, June => 6, July => 7, August => 8,
    September => 9, October => 10, November => 11, December => 12
);

sub _get_metadata_date {
    my $self = shift;
    my $metadata_name = shift;
    my %params = @_;

    my ($mm, $year) = @params{'month', 'year'};
    
    ## If $year & $month are not specified, we assume the user wants the most recent month that 
    ## we have metadata for...
    if (!defined $year && !defined $mm) {
        my $ra_metadata = $self->{'metadata'}->{$metadata_name};
    
        my @a_found_months = ();
        foreach my $item ($ra_metadata){
            ## can be 2007_q4 or 2007_m10
            my @a_dates_this_item = keys %{$item->{'data'}};        
            push(@a_found_months, grep { m!\d_m\d! } @a_dates_this_item);
        }
        my ($date) = sort { _month_to_yyyymmdd($b) <=> _month_to_yyyymmdd($a) } @a_found_months;
        return $date;
    }
    elsif ($params{'range'} eq 'monthly') {
        my $month = exists $short_months{$mm}
                         ? $short_months{$mm}
                         : exists $long_months{$mm}
                                ? $long_months{$mm}
                                : $mm;
    
        if ($month == 0) {
            $month = 12;
            $year--;
        }

        return sprintf '%d_m%d', $year, $month;
    }

    return;
}

sub _month_to_yyyymmdd {
    my $month = shift;
    if ( $month =~ m/(\d\d\d\d)_m(\d+)/ ){
        return sprintf('%04d%02d%02d', $1, $2, 1 );
    }
    return;
}

=head1 Copyright

Copyright (C) 2009 Lokku Ltd.

=head1 Author

Alex Balhatchet (alex@lokku.com)

Patches supplied by Yoav Felberbaum and Alistair Francis.

=cut

1;
