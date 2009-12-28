package Newmo::V::MT::Context;
use Amon::V::MT::Context;
use HTTP::MobileAgent;

sub mobile_agent {
    HTTP::MobileAgent->new(req->headers());
}

sub show_hatena_users_count {
    my $entry = shift;
    if ($entry->hatenabookmark_users) {
        encoded_string(qq{<a href="http://b.hatena.ne.jp/entry/@{[  $entry->link ]}" class="users">@{[  $entry->hatenabookmark_users ]}users</a>});
    } else {
        '';
    }
}

1;
