use ExtUtils::MakeMaker;
WriteMakefile
(
    'PL_FILES' => {},
    'INSTALLDIRS' => 'site',
    'NAME' => 'WebService::Nestoria::Search',
    'EXE_FILES' => [],
    'VERSION_FROM' => 'lib/WebService/Nestoria/Search.pm',
    'PREREQ_PM' => {
                   'Test::More' => 0,
                   'URI' => 0,
                   'LWP::UserAgent' => 0,
                   'Module::Build' => 0,
                   'JSON' => 2.0,
                   'HTTP::Request' => 0,
                   'Carp' => 0,
                   'version' => 0,
                   'XML::Simple' => 0,
                 },
    'AUTHOR' => 'Alex Balhatchet (kaoru at slackwise dot net), Yoav Felberbaum (perl at mrdini dot com), Alistair Francis (cpan at alizta dot com)',
    'ABSTRACT' => 'WebService::Nestoria::Search provides a Perl interface to the public API of Nestoria, a vertical search engine for property listings. Nestoria currently has listings for the UK, Germany, Italy and Spain, which can be accessed via the web at www.nestoria.co.uk, www.nestoria.de, www.nestoria.co.it and www.nestoria.es.',
);
