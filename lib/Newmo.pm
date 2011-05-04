package Newmo;
use strict;
use warnings;
use parent qw/Amon2/;
use Carp ();

our $VERSION = '0.01';

use Amon2::Config::Simple;
sub load_config { Amon2::Config::Simple->load(shift) }

use Newmo::DB;
sub db {
    my ($c) = @_;
    $c->{db} //= do {
        my $conf = $c->config->{'DB'} // die "missing configuration for db";
        Newmo::DB->new($conf);
    };
}

1;
