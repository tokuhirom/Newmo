use File::Spec;

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
        'http://feeds.delicious.com/v2/rss/?count=15',
    ],
}
