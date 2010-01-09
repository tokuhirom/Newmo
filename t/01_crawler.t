use strict;
use warnings;
use Test::More;
use t::Utils;
use File::Temp qw/tempfile/;
use Newmo;

my ($dedup_fh, $dedup_fn) = tempfile();

my $c = setup_standalone();

note "setuped db";
my $crawler = $c->get('Crawler', $dedup_fn);
note "ready to run";
$crawler->crawl('http://blog.livedoor.jp/dankogai/index.rdf');
ok 'works';
done_testing;

