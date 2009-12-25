use strict;
use warnings;
use Newmo::Crawler;
use Newmo::M::DB::Feed;
use File::Temp qw/tempfile/;
use File::Spec;
use Test::More;

my $db = Newmo::M::DB::Feed->new({
    dsn => 'dbi:SQLite:',
});

my ($dedup_fh, $dedup_fn) = tempfile();

my $sql = slurp('sql/newmo.sql');
for my $s (split /;/, $sql) {
    next if $s !~ /\S/;
    $db->dbh->do($s) or die $db->dbh->error;
}

my $crawler = Newmo::Crawler->new(
    db         => $db,
    dedup_file => $dedup_fn,
);
is ref($crawler->ldrfullfeed_data()), 'ARRAY';
$crawler->crawl('http://blog.livedoor.jp/dankogai/index.rdf');
done_testing;

sub slurp {
    my $file = shift;
    open my $fh, '<', $file or die $!;
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content;
}

