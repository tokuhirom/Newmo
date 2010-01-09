package Newmo;
use Amon -base;
use LWP::UserAgent::WithCache ();
use HTML::Scrubber            ();

__PACKAGE__->add_factory(
    'HTML::Scrubber' => sub {
        my ($c, $klass, $conf) = @_;
        my $scrubber = HTML::Scrubber->new();
           $scrubber->rules($conf->{rules});
           $scrubber->default($conf->{default});
           $scrubber;
    }
);
__PACKAGE__->add_factory(
    'LWP::UserAgent::WithCache' => sub {
        my ($c, $klass, $conf ) = @_;
        return LWP::UserAgent::WithCache->new(
            $conf || +{}
        );
    }
);
__PACKAGE__->add_factory(
    'Crawler' => sub {
        my ($c, $klass, $conf, $dedup_file ) = @_;
        Newmo::Crawler->new(
            db         => $c->model('DB::Feed'),
            ua         => $c->get('LWP::UserAgent::WithCache'),
            scrubber   => $c->get('HTML::Scrubber'),
            dedup_file => $dedup_file,
        );
    },
);

1;
