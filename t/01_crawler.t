use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../extlib/lib/perl5/');
use lib File::Spec->catdir(dirname(__FILE__), '../lib');
use Test::More;
use t::Utils;
use File::Temp qw/tempfile/;
use Newmo;
use Newmo::Crawler;
use File::Basename qw/dirname/;
use Cwd 'abs_path';
use HTML::Scrubber;

my ($dedup_fh, $dedup_fn) = tempfile();

my $c = setup_standalone();

note "setuped db";
my $crawler = Newmo::Crawler->new(db => $c->db, scrubber => HTML::Scrubber->new());
note "ready to run";
my $path = abs_path(dirname(__FILE__));
$crawler->crawl( "file://$path/data/feed.rss" );
ok 'works';
done_testing;

