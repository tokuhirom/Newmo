use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '..', 'lib');
use lib File::Spec->catfile($FindBin::Bin, '..', 'vender', 'HTML-EFT', 'lib');
use lib File::Spec->catfile($FindBin::Bin, '..', 'vendor', 'Amon', 'lib');
use Try::Tiny;
use Newmo;
use Newmo::Crawler;
use HTML::Scrubber;

&main;exit;

# -------------------------------------------------------------------------

sub main {
    my $c = Newmo->bootstrap();

    my $scrubber = do {
        my $conf = $c->config->{'HTML::Scrubber'} // die;
        my $s = HTML::Scrubber->new();
           $s->rules( $conf->{rules} );
           $s->default( $conf->{default} );
           $s;
    };
    my $crawler = Newmo::Crawler->new(db => $c->db, scrubber => $scrubber );

    for my $feed (@{ $c->config->{feeds} }) {
        try {
            $crawler->crawl($feed);
        } catch {
            print STDERR "ERROR: $feed: $_\n";
        };
    }
}

