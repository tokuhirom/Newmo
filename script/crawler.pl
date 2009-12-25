use strict;
use warnings;
use Newmo::Crawler;
use File::Temp qw(tempfile);
use Getopt::Long;

my $conffile = 'config.yaml';
GetOptions(
    'c|config=s' => \$conffile,
);

my $dedup_file = tempfile();

my $conf = do $conffile;

my $db = Newmo::M::DB::Feed->new($conf->{'M::DB::Feed'});
my $ua = LWP::UserAgent::WithCache->new(
    $conf->{'LWP::UserAgent::WithCache'} || +{}
);
my $crawler = Newmo::Crawler->new(
    db         => $db,
    dedup_file => "$dedup_file",
    ua         => $ua,
);
my $MAX_REQUESTS_PER_CHILD = 100;

&main;exit;

# -------------------------------------------------------------------------

sub main {
    my $i = 0;
    while ($i < $MAX_REQUESTS_PER_CHILD) {
        for my $feed (@{ $conf->{feeds} }) {
            $crawler->crawl($feed);
        }
        sleep 60*60; # per hour
    }
}

