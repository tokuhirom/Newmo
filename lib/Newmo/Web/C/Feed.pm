package Newmo::Web::C::Feed;
use strict;
use warnings;

sub show {
    my ($class, $c, $feed_id) = @_;
    my $page = $c->req->param('page') || 1;
    my $rows_per_page = 20;

    my $feed =
      $c->db->dbh->selectrow_hashref( q{SELECT * FROM feed WHERE feed_id=?},
        {}, $feed_id ) // die;
    my @entries = @{$c->db->dbh->selectall_arrayref(
        sprintf(q{SELECT * FROM entry WHERE feed_id=? ORDER BY entry_id DESC LIMIT %d OFFSET %d}, $rows_per_page + 1, $rows_per_page*$page),
        {Slice => {}},
        $feed_id,
    )};
    warn $feed_id;
    warn scalar @entries;
    my $has_next =  ($rows_per_page+1 == @entries);
    if ($has_next) { pop @entries }

    $c->render(
        'feed.mt', $feed, \@entries, $page, $has_next
    );
}

1;
