use strict;
use warnings;
use Test::More;
use t::Utils;
use File::Temp qw/tempfile/;
use Newmo;
use File::Basename qw/dirname/;
use Cwd 'abs_path';

my ($dedup_fh, $dedup_fn) = tempfile();

my $c = setup_standalone();

note "setuped db";
my $crawler = $c->get('Crawler', $dedup_fn);
note "ready to run";
my $path = abs_path(dirname(__FILE__));
$crawler->crawl( "file://$path/data/feed.rss" );
ok 'works';
done_testing;

