use inc::Module::Install;

name     'DBIx-Moo';
all_from 'lib/DBIx/Moo.pm';
author   q{Brad Haywood <brad@perlpowered.com>};
license  'perl';

build_requires 'Test::More';
requires (
    'Moo',
    'Clone',
    'Scalar::Util',
    'DBIx::Connector',
    'SQL::Abstract::More',
    'DBIx::Admin::TableInfo',
);

auto_install;

WriteAll;

