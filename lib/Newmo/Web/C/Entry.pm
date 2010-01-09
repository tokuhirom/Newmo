package Newmo::Web::C::Entry;
use Amon::Web::C;

sub show {
    my ($class, $entry_id, $page_no) = @_;
    my $entry = db->single(
        'entry' => { entry_id => $entry_id }
    );
    my $entry_page_count = db->search_by_sql(
        q{SELECT COUNT(entry_id) as cnt FROM entry_page where entry_id=?},
        [$entry_id]
    )->first->cnt;
    my $entry_page = db->single(
        'entry_page' => { entry_id => $entry_id, page_no => $page_no },
    );
    unless ($entry_page) {
        warn "cannot get entry_page";
        return res_404();
    }

    render(
        'entry.mt',
        $entry,
        $entry_page,
        $entry_page_count,
    );
}

1;
