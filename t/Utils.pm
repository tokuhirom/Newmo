package t::Utils;
use strict;
use warnings;
use base qw/Exporter/;
our @EXPORT = qw/setup_standalone setup_webapp/;
use Newmo;
use Newmo::Web;
use DBI;
use Test::mysqld;
use Test::More;

our $CONFIG = {
    'Logger' => {
        loggers => [
            'Screen::Color' => {
                min_level => 'debug',
                name      => 'debug',
                stderr    => 1,
                color     => {
                    debug => {
                        text => 'green',
                    }
                }
            },
        ],
    },
};
our $SCHEMA  = 'sql/newmo.mysql.sql';

sub setup_standalone {
    my $mysqld = setup_mysqld();
    return Newmo->bootstrap(config => $CONFIG, mysqld => $mysqld);
}

sub setup_webapp {
    my $mysqld = setup_mysqld();
    Newmo::Web->to_app(config => $CONFIG, mysqld => $mysqld);
}

sub setup_mysqld {
    my $mysqld = Test::mysqld->new(
        my_cnf => {
            'skip-networking' => '',    # no TCP socket
        }
    ) or plan skip_all => $Test::mysqld::errstr;
    my $dbh = DBI->connect($mysqld->dsn()) or die;
    for my $sql (split /;/, slurp($SCHEMA)) {
        next unless $sql =~ /\S/;
        $dbh->do("$sql") or die;
    }
    $CONFIG->{'DB'}->{dsn} = $mysqld->dsn;
    return $mysqld;
}

sub slurp {
    my $fname = shift;
    open my $fh, '<:utf8', $fname or die "cannot open $fname: $!";
    my $ret = do {local $/; <$fh>};
    close $fh;
    $ret;
}

1;
