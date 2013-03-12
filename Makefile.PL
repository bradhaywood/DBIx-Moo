use inc::Module::Install;

name     'DBIx-Moo';
all_from 'lib/DBIx/Moo.pm';
author   q{Brad Haywood <brad@perlpowered.com>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

