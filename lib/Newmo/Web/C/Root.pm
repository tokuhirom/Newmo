package Newmo::Web::C::Root;
use Amon::Web::C;

sub index {
    my @feeds = db->search('feed' => {}, {order_by => 'feed_id'});
    my %feed2entries;
    for my $feed (@feeds) {
        my (@entries) = db->search_by_sql(
            q{SELECT SQL_CACHE entry_id, feed_id, link, title, hatenabookmark_users FROM entry WHERE feed_id=? ORDER BY entry_id DESC LIMIT 20},
            [$feed->feed_id],
        );
        $feed2entries{$feed->feed_id} = \@entries;
    }

    render(
        'index.mt',
        \@feeds,
        \%feed2entries
    );
}

1;
