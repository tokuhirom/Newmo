use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use File::Temp qw(tempfile);
use Getopt::Long;
use Newmo::Crawler;
use Newmo::M::DB::Feed;
use LWP::UserAgent::WithCache;
use HTML::Scrubber;
use Try::Tiny;

my $conffile = 'config.pl';
GetOptions(
    'c|config=s' => \$conffile,
);

my ($dedup_fh, $dedup_file) = tempfile();

die "cannot read configuration file: $conffile" unless -f $conffile;
my $conf = do $conffile;

my $db = Newmo::M::DB::Feed->new($conf->{'M::DB::Feed'});
my $ua = LWP::UserAgent::WithCache->new(
    $conf->{'LWP::UserAgent::WithCache'} || +{}
);
my $scrubber = HTML::Scrubber->new();
$scrubber->rules($conf->{'HTML::Scrubber'}->{rules});
$scrubber->default($conf->{'HTML::Scrubber'}->{default});
my $crawler = Newmo::Crawler->new(
    db         => $db,
    dedup_file => $dedup_file,
    ua         => $ua,
    scrubber   => $scrubber,
);

&main;exit;

# -------------------------------------------------------------------------

sub main {
    for my $feed (@{ $conf->{feeds} }) {
        try {
            $crawler->crawl($feed);
        } catch {
            print STDERR "ERROR: $feed: $_\n";
        };
    }
}

