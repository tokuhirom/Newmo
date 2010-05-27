package Newmo;
use Amon -base;
use Carp ();

__PACKAGE__->add_factory(
    'HTML::Scrubber' => sub {
        my ($c, $klass, $conf) = @_;
        Amon::Util::load_class($klass);
        my $scrubber = HTML::Scrubber->new();
           $scrubber->rules($conf->{rules});
           $scrubber->default($conf->{default});
           $scrubber;
    }
);
__PACKAGE__->add_factory(
    'LWP::UserAgent::WithCache' => sub {
        my ($c, $klass, $conf ) = @_;
        Amon::Util::load_class($klass);
        return $klass->new(
            $conf || +{}
        );
    }
);
__PACKAGE__->add_factory(
    'Crawler' => sub {
        my ($c, $name, $conf) = @_;
        my $klass = "Newmo::Crawler";
        Amon::Util::load_class($klass);
        $klass->new(
            db         => $c->get('DB'),
            ua         => $c->get('LWP::UserAgent::WithCache'),
            scrubber   => $c->get('HTML::Scrubber'),
            %$conf,
        );
    },
);
__PACKAGE__->add_factory(
    'Cache::Memcached::Fast' => sub {
        my ($c, $klass, $conf) = @_;
        Amon::Util::load_class($klass);
        Cache::Memcached::Fast->new($conf);
    }
);

sub memcached { $_[0]->get('Cache::Memcached::Fast') }

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
