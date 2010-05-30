package Newmo::V::Xslate::Context;
use strict;
use warnings;
use Amon::Web::Declare;
use HTTP::MobileAgent;
use Exporter 'import';
use Text::Xslate qw/escaped_string/;

our @EXPORT = qw/mobile_agent uri_for show_hatena_users_count raw time/;
*raw = *escaped_string;

sub time { CORE::time() }

sub mobile_agent {
    HTTP::MobileAgent->new(req->headers());
}

sub show_hatena_users_count {
    my $entry = shift;
    if ($entry->{hatenabookmark_users}) {
        escaped_string(qq{<a href="http://b.hatena.ne.jp/entry/@{[  $entry->{link} ]}" class="users">@{[  $entry->{hatenabookmark_users} ]}users</a>});
    } else {
        '';
    }
}

1;
