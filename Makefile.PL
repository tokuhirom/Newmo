use inc::Module::Install;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib/lib/perl5/');

all_from 'lib/Newmo.pm';
license 'perl';

requires(
    'HTTP::MobileAgent'         => 0,
    'Cache::Memcached::Fast'    => 0,
    'HTML::ExtractContent'      => 0,
    'HTML::ResolveLink'         => 0,
    'HTML::TreeBuilder::LibXML' => 0,
    'JSON'                      => 0,
    'LWP::UserAgent'            => 0,
    'Mouse'                     => 0.90,
    'URI'                       => 0,
    'XML::Feed'                 => 0,
    'XML::Feed::Deduper'        => 0,
    'HTML::Split'               => 0,
    'Amon2'                     => '2.32',
    'DBIx::Skinny'              => 0,
    'Text::Xslate'              => 0.1026,
    'Log::Dispatch'             => 0,
    'Log::Minimal'              => 0,
	'DBD::mysql'                => 0,
	'Scope::Guard'              => 0,
	'HTML::Scrubber'            => 0,
	'Try::Tiny'                 => 0,
);

can_run('cronlog') or do {
	use File::Temp;
	my $tmp = File::Temp->new(UNLINK => 1);
	system "curl -L --output $tmp http://github.com/kazuho/kaztools/tarball/master";
	system "cpanm -nv $tmp";
};

test_requires 'Test::Requires';

tests 't/*.t t/*/*.t t/*/*/*.t';
recursive_author_tests('xt');
WriteAll;
