package Newmo::Web::Dispatcher;
use strict;
use warnings;
use Amon::Web::Dispatcher;
use Newmo::Web::C::Root;
use Newmo::Web::C::Feed;
use Newmo::Web::C::Entry;
use 5.010;

sub dispatch {
    my ($class, $req) = @_;

    given ($req->path_info) {
        when ('/') {
            Newmo::Web::C::Root->index();
        }
        when (qr{^/feed/(\d+)$}) {
            Newmo::Web::C::Feed->show($1);
        }
        when (qr{^/entry/(\d+)/(\d+)$}) {
            # $1=entry_id, $2=page_no
            Newmo::Web::C::Entry->show($1, $2);
        }
        default {
            res_404();
        }
    }
}

1;
