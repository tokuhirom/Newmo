use inc::Module::Install;

all_from 'lib/Newmo.pm';
license 'perl';

test_requires 'Test::Requires';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests('xt');
auto_include;
auto_install;
auto_set_repository;

WriteAll;
