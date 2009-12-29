use strict;
use warnings;
use FindBin;
use File::Spec;
use lib File::Spec->catfile($FindBin::Bin, 'lib');
use Newmo::Web;
use Plack::App::File;
use Plack::App::URLMap;
use File::Basename;

my $basedir = File::Spec->rel2abs(dirname(__FILE__));

my $config = do 'config.pl';
my $app = Newmo::Web->to_app(
    config => $config
);

my $map = Plack::App::URLMap->new();
$map->map('/static/' => Plack::App::File->new({root => File::Spec->catdir($basedir, 'htdocs/static')})->to_app);
$map->map('/' => $app);
$map->to_app;

