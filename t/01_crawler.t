use strict;
use warnings;
use Newmo::Crawler;
use Newmo::M::DB::Feed;
use File::Temp qw/tempfile/;
use File::Spec;
use Test::More;
use HTML::Scrubber;
use t::Utils;

my ($dedup_fh, $dedup_fn) = tempfile();

my $c = setup_standalone();
my $db = $c->model('DB::Feed');

note "setuped db";
my $scrubber = HTML::Scrubber->new();
my $crawler = Newmo::Crawler->new(
    db         => $db,
    dedup_file => $dedup_fn,
    scrubber   => $scrubber,
);
note "ready to run";
$crawler->crawl('http://blog.livedoor.jp/dankogai/index.rdf');
ok 'works';
done_testing;

