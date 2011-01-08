package Newmo::Web::C::Root;
use strict;
use warnings;

sub index {
    my ($class, $c) = @_;

    my @feeds = @{$c->memcached->get_or_set_cb(
        'feeds:3' => 24*60*60 => sub {
            $c->db->dbh->selectall_arrayref(q{SELECT * FROM feed ORDER BY feed_id ASC}, {Slice => {}});
        }
    )};
    for my $feed (@feeds) {
        my (@entries) = @{$c->db->dbh->selectall_arrayref(
            q{SELECT SQL_CACHE entry_id, feed_id, link, title, hatenabookmark_users FROM entry WHERE feed_id=? ORDER BY entry_id DESC LIMIT 20},
            {Slice => {}},
            $feed->{feed_id},
        )};
        $feed->{entries} = \@entries;
    }

    $c->render(
        'index.mt',
        {
            feeds        => \@feeds,
        },
    );
}

1;
