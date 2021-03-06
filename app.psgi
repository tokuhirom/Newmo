use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib/lib/perl5/');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Newmo::Web;
use Plack::App::File;
use File::Basename;
use Plack::Builder;

builder {
    enable 'Plack::Middleware::Static',
        path => qr{^/static/},
        root => './';
    enable 'Plack::Middleware::ReverseProxy';

    Newmo::Web->to_app();
};

