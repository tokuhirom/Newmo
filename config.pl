use File::Spec;
my $cachedir = File::Spec->catfile(File::Spec->tmpdir, "newmo.cache.$<");
mkdir $cachedir unless -d $cachedir;

{
    'DB' => {
        dsn             => 'dbi:mysql:database=dev_Newmo',
        username => 'root',
        password => '',
        connect_options => +{
            mysql_read_default_file => '/etc/mysql/my.cnf',
            mysql_enable_utf8       => 1,
        },
    },
    feeds      => [
#       'http://blog.livedoor.jp/dankogai/index.rdf',
        'http://b.hatena.ne.jp/entrylist?mode=rss&sort=hot&threshold=5',
        'http://b.hatena.ne.jp/hotentry?mode=rss',
        'http://b.hatena.ne.jp/hotentry/news/rss',
        'http://feeds.digg.com/digg/container/technology/popular.rss',
        'http://api.pathtraq.com/newsite',
        'http://api.pathtraq.com/popular?__lang=ja',
        'http://delicious.com/?view=hotlist',
    ],
    'LWP::UserAgent::WithCache' => {
        parse_head => 0,
        'namespace' => 'lwp-cache',
        cache_root => $cachedir,
        default_expires_in => 600,
    },
    'HTML::Scrubber' => {
        rules => {
            img => {
                src => qr{^http://},    # only URL with http://
                alt => 1,               # alt attributes allowed
                '*' => 0,               # deny all others
            },
            style  => 0,
            script => 0,
            'link' => {
                href => qr{^http://},    # only URL with http://
                rel  => 1,
                type => 1,
            },
        },
        default => {
            '*' => 0,                    # default rule, deny all attributes
            'href'     => qr{^(?!(?:java)?script)}i,
            'src'      => qr{^(?!(?:java)?script)}i,
            'cite'     => '(?i-xsm:^(?!(?:java)?script))',
            'language' => 0,
            'name'        => 1,           # could be sneaky, but hey ;)
            'onblur'      => 0,
            'onchange'    => 0,
            'onclick'     => 0,
            'ondblclick'  => 0,
            'onerror'     => 0,
            'onfocus'     => 0,
            'onkeydown'   => 0,
            'onkeypress'  => 0,
            'onkeyup'     => 0,
            'onload'      => 0,
            'onmousedown' => 0,
            'onmousemove' => 0,
            'onmouseout'  => 0,
            'onmouseover' => 0,
            'onmouseup'   => 0,
            'onreset'     => 0,
            'onselect'    => 0,
            'onsubmit'    => 0,
            'onunload'    => 0,
            'src'         => 0,
            'type'        => 0,
            'style'       => 0,
            'loop'        => qr{^\d+$},
            'behaivour' => qr{^(?:scroll|alternate|slide)$},
        }
    },
}
