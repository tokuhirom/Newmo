BEGIN {
    $|++;

    print "perl: $^X\n";
    print "PLACK_ENV: $ENV{PLACK_ENV}\n";
}
use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, '../../lib');
use lib File::Spec->catfile($FindBin::Bin, '../../extlib/lib/perl5/');
use Try::Tiny;
use Newmo;
use Newmo::Crawler;

&main;exit;

# -------------------------------------------------------------------------

sub main {
    my $c = Newmo->bootstrap();

    my $crawler = Newmo::Crawler->new(db => $c->db );

    for my $feed (@{ $c->config->{feeds} }) {
        try {
            $crawler->crawl($feed);
        } catch {
            print STDERR "ERROR: $feed: $_\n";
        };
    }
}

