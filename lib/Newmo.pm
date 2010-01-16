package Newmo;
use Amon -base;

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

1;
