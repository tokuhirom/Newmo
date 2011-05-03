package Newmo::Web;
use strict;
use warnings;
use parent qw/Newmo Amon2::Web/;

# load all controller classes
use Module::Find ();
Module::Find::useall("Newmo::Web::C");

# dispatcher
use Newmo::Web::Dispatcher;
sub dispatch {
    return Newmo::Web::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

use Text::Xslate qw/escaped_string/;

# setup view class
use Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    my $view = Text::Xslate->new(
        path   => ['./tmpl/'],
        module => ['Data::Dumper', 'Newmo::V::Xslate::Context'],
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::TT2Like' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            mobile_agent => sub { Amon2->context->mobile_agent },
            time         => sub { CORE::time() },
            show_hatena_users_count => sub { # TODO: remove this.
                my $entry = shift;
                if ($entry->{hatenabookmark_users}) {
                    escaped_string(qq{<a href="http://b.hatena.ne.jp/entry/@{[  $entry->{link} ]}" class="users">@{[  $entry->{hatenabookmark_users} ]}users</a>});
                } else {
                    '';
                }
            }
        },
        %$view_conf,
    );
    sub create_view { $view }
}

# load plugins
__PACKAGE__->load_plugins('Web::NoCache');
__PACKAGE__->load_plugins('Web::MobileAgent');

1;
