package Newmo::Web::C::Feed;
use Amon::Web::C;

sub show {
    my ($class, $feed_id) = @_;
    my $page = param('page') || 1;
    my $rows_per_page = 20;

    my ($feed) = db->search('feed' => { feed_id => $feed_id } );
    my @entries = db->search(
        'entry' => { feed_id => $feed_id },
        {
            order_by => {'entry_id' => 'DESC'},
            limit    => $rows_per_page+1,
            offset   => $rows_per_page*$page,
        }
    );
    my $has_next =  ($rows_per_page+1 == @entries);
    if ($has_next) { pop @entries }

    render(
        'feed.mt', $feed, \@entries, $page, $has_next
    );
}

1;
