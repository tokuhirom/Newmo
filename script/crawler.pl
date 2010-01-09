use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use lib File::Spec->catfile($FindBin::Bin, '..', 'vender', 'HTML-EFT', 'lib');
use lib File::Spec->catfile($FindBin::Bin, '..', 'vendor', 'Amon', 'lib');
use File::Temp qw(tempfile);
use Getopt::Long;
use Try::Tiny;
use Newmo;

my $conffile = 'config.pl';
GetOptions(
    'c|config=s' => \$conffile,
);

die "cannot read configuration file: $conffile" unless -f $conffile;
my $conf = do $conffile;

&main;exit;

# -------------------------------------------------------------------------

sub main {
    my ($dedup_fh, $dedup_file) = tempfile();
    my $c = Newmo->bootstrap(config => $conf);
    my $crawler = $c->get('Crawler', $dedup_file);

    for my $feed (@{ $conf->{feeds} }) {
        try {
            $crawler->crawl($feed);
        } catch {
            print STDERR "ERROR: $feed: $_\n";
        };
    }
}

