package Newmo::Web::C::Root;
use Amon::Web::C;

sub index {
    my @feeds = model('DB::Feed')->search('feed' => {}, {order_by => 'feed_id'});
    my %feed2entries;
    for my $feed (@feeds) {
        my (@entries) = model('DB::Feed')->search(
            'entry' => { feed_id => $feed->feed_id },
            { order_by => { 'entry_id' => 'desc' }, limit => 20 }
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
