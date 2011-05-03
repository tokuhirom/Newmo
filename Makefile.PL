use inc::Module::Install;

all_from 'lib/Newmo.pm';
license 'perl';

requires(
    'HTTP::MobileAgent'         => 0,
    'HTML::ExtractContent'      => 0,
    'HTML::ResolveLink'         => 0,
    'HTML::TreeBuilder::LibXML' => 0,
    'JSON'                      => 0,
    'LWP::UserAgent'            => 0,
    'Mouse'                     => 0,
    'URI'                       => 0,
    'XML::Feed'                 => 0,
    'XML::Feed::Deduper'        => 0,
    'HTML::Split'               => 0,
    'Amon2'                     => '2.32' => 0,
    'DBIx::Skinny'              => 0,
    'Text::Xslate'              => 0.1026,
    'Log::Dispatch'             => 0,
	'Cache::Memcached::Fast'    => 0,
);

test_requires 'Test::Requires';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests('xt');
WriteAll;
