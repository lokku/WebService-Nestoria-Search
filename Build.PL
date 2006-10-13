#!/usr/bin/perl -w

use strict;
use Module::Build;

my $builder = Module::Build->new (
    module_name       => 'WebService::Nestoria::Search',
    license           => 'perl',
    dist_author       => 'Alex Balhatchet (kaoru@slackwise.net)',
    dist_version_from => 'lib/WebService/Nestoria/Search.pm',

    requires => {
        'Carp'           => 0,
        'HTTP::Request'  => 0,
        'JSON'           => 0,
        'LWP::UserAgent' => 0,
        'URI'            => 0,
    },

    build_requires => {
        'Module::Build'  => 0,
        'Test::More'     => 0,
    },

    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
