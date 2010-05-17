use inc::Module::Install;

all_from 'lib/Newmo.pm';
license 'perl';

requires 'HTTP::MobileAgent';
requires 'HTML::ExtractContent';
requires 'HTML::ResolveLink';
requires 'HTML::TreeBuilder::LibXML';
requires 'JSON';
requires 'LWP::UserAgent';
requires 'Mouse';
requires 'URI';
requires 'XML::Feed';
requires 'XML::Feed::Deduper';
requires 'XMLRPC::Lite';
requires 'HTML::Split';
requires 'Amon';
requires 'DBIx::Skinny';
requires 'LWP::UserAgent::WithCache';

test_requires 'Test::Requires';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests('xt');
auto_include;
WriteAll;
