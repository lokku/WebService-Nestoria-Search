#!/usr/bin/perl -w

use strict;
use Module::Build;

my $builder = Module::Build->new (
    module_name       => 'WebService::Nestoria::Search',
    license           => 'perl',
    dist_author       => 'Alex Balhatchet (alex@lokku.com)',
    dist_version_from => 'lib/WebService/Nestoria/Search.pm',
    dist_abstract => 'WebService::Nestoria::Search provides a Perl interface to the public API of Nestoria, a vertical search engine for property listings.',

    requires => {
        'Carp'            => 0,
        'HTTP::Request'   => 0,
        'JSON'            => 2.0,
        'LWP::UserAgent'  => 0,
        'URI'             => 0,
        'version'         => 0,
        'XML::Simple'     => 0,
    },

    build_requires => {
        'Module::Build'   => 0,
        'Test::More'      => 0,
        'Test::Warn'      => 0,
        'List::MoreUtils' => 0,
    },

    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
