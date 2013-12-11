use strict;
use warnings;

package WebService::Nestoria::Search::Result;
{
  $WebService::Nestoria::Search::Result::VERSION = '1.021005';
}

=head1 NAME

WebService::Nestoria::Search::Result - Container object for a WebService::Nestoria::Search result.

=head1 VERSION

version 1.021005

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
    get_price_high
    get_price_low
    get_price_coldrent
    get_title
    get_summary
    get_bedroom_number
    get_bathroom_number
    get_room_number
    get_size
    get_size_unit
    get_land_size
    get_land_size_unit
    get_thumb_url
    get_thumb_height
    get_thumb_width
    get_img_url
    get_img_height
    get_img_width
    get_keywords
    get_guid
    get_commission
    get_construction_year
    get_auction_date
    get_updated_in_days
    get_updated_in_days_formatted
    get_location_accuracy

=cut

sub get_latitude                  { shift->{data}{listing}{latitude}                      }
sub get_longitude                 { shift->{data}{listing}{longitude}                     }
sub get_listing_type              { shift->{data}{listing}{listing_type}                  }
sub get_property_type             { shift->{data}{listing}{property_type}                 }
sub get_datasource_name           { shift->{data}{listing}{datasource_name}               }
sub get_lister_name               { shift->{data}{listing}{lister_name}                   }
sub get_lister_url                { shift->{data}{listing}{lister_url}                    }
sub get_price                     { shift->{data}{listing}{price}                         }
sub get_price_type                { shift->{data}{listing}{price_type}                    }
sub get_price_currency            { shift->{data}{listing}{price_currency}                }
sub get_price_formatted           { shift->{data}{listing}{price_formatted};              }
sub get_price_high                { shift->{data}{listing}{price_high};                   }
sub get_price_low                 { shift->{data}{listing}{price_low};                    }
sub get_price_coldrent            { shift->{data}{listing}{price_coldrent};               }
sub get_title                     { shift->{data}{listing}{title}                         }
sub get_summary                   { shift->{data}{listing}{summary}                       }
sub get_bedroom_number            { shift->{data}{listing}{bedroom_number}                }
sub get_bathroom_number           { shift->{data}{listing}{bathroom_number}               }
sub get_room_number               { shift->{data}{listing}{room_number}                   }
sub get_size                      { shift->{data}{listing}{size}                          }
sub get_size_unit                 { shift->{data}{listing}{size_unit}                     }
sub get_land_size                 { shift->{data}{listing}{land_size}                     }
sub get_land_size_unit            { shift->{data}{listing}{land_size_unit}                }
sub get_thumb_url                 { shift->{data}{listing}{thumb_url}                     }
sub get_thumb_height              { shift->{data}{listing}{thumb_height}                  }
sub get_thumb_width               { shift->{data}{listing}{thumb_width}                   }
sub get_img_url                   { shift->{data}{listing}{img_url}                       }
sub get_img_height                { shift->{data}{listing}{img_height}                    }
sub get_img_width                 { shift->{data}{listing}{img_width}                     }
sub get_keywords                  { shift->{data}{listing}{keywords}                      }
sub get_guid                      { shift->{data}{listing}{guid}                          }
sub get_updated_in_days           { shift->{data}{listing}{updated_in_days}               }
sub get_updated_in_days_formatted { shift->{data}{listing}{updated_in_days_formatted}     }
sub get_construction_year         { shift->{data}{listing}{construction_year}             }
sub get_commission                { shift->{data}{listing}{commission}                    }
sub get_auction_date              { shift->{data}{listing}{auction_date}                  }
sub get_location_accuracy         { shift->{data}{listing}{location_accuracy}             }

=head2 get_hashref

Returns a hashref containing the details of the listing with keys exactly as the list above. For example:

    use Data::Dumper;
    print Dumper($result->get_hashref);

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

Copyright (C) 2009 Lokku Ltd.

=head1 Author

Alex Balhatchet (alex@lokku.com)

Patches supplied by Yoav Felberbaum and Alistair Francis.

=cut

1;
