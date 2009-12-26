package Newmo::Web::C::Entry;
use Amon::Web::C;

sub show {
    my ($class, $entry_id, $page_no) = @_;
    my ($entry) = model('DB::Feed')->single(
        'entry' => { entry_id => $entry_id }
    );
    my ($entry_page) = model('DB::Feed')->single(
        'entry_page' => { entry_id => $entry_id, page_no => $page_no },
    );
    my $entry_page_count = model('DB::Feed')->search_by_sql(
        q{SELECT COUNT(entry_id) as cnt FROM entry_page where entry_id=?},
        [$entry_id]
    )->first->cnt;

    render(
        'entry.mt',
        $entry,
        $entry_page,
        $entry_page_count,
    );
}

1;
