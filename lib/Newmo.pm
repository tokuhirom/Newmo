package Newmo;
use strict;
use warnings;
use parent qw/Amon2/;
use Carp ();

our $VERSION = '0.01';

use Amon2::Config::Simple;
sub load_config { Amon2::Config::Simple->load(shift) }

__PACKAGE__->load_plugins(qw/LogDispatch/);

use Cache::Memcached::Fast;
sub memcached {
    my ($c, ) = @_;
    my $conf = $c->config->{'Cache::Memcached::Fast'} // die "missing configuration for memcached";
    Cache::Memcached::Fast->new($conf);
}

use Newmo::DB;
sub db {
    my ($c) = @_;
    $c->{db} //= do {
        my $conf = $c->config->{'DB'} // die "missing configuration for db";
        Newmo::DB->new($conf);
    };
}

sub Cache::Memcached::Fast::get_or_set_cb {
    my ( $self, $key, $expire, $cb ) = @_;
    my $data = $self->get($key);
    return $data if defined $data;
    $data = $cb->();
    $self->set( $key, $data, $expire )
      or Carp::carp(
        "Cannot set $key to memcached"
      );
    return $data;
}

1;
