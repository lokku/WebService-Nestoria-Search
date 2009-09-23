#!/usr/bin/perl -w

use strict;
use Module::Build;

my $builder = Module::Build->new (
    module_name       => 'WebService::Nestoria::Search',
    license           => 'perl',
    dist_author       => 'Alex Balhatchet (kaoru at slackwise dot net), Yoav Felberbaum (perl at mrdini dot com), Alistair Francis (cpan at alizta dot com)',
    dist_version_from => 'lib/WebService/Nestoria/Search.pm',
    dist_abstract => 'WebService::Nestoria::Search provides a Perl interface to the public API of Nestoria, a vertical search engine for property listings. Nestoria currently has listings for the UK, Germany, Italy and Spain, which can be accessed via the web at www.nestoria.co.uk, www.nestoria.de, www.nestoria.co.it and www.nestoria.es.',

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
