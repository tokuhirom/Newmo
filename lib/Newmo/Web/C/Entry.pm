package Newmo::Web::C::Entry;
use strict;
use warnings;

sub show {
    my ($class, $c, $args) = @_;
    my $entry_id = $args->{entry_id} // die;
    my $page_no = $args->{page_no} // die;

    my $entry = $c->db->dbh->selectrow_hashref(
        q{SELECT *, FROM_UNIXTIME(issued) AS issued, FROM_UNIXTIME(modified) AS modified FROM entry WHERE entry_id=?},
        {},
        $entry_id
    );
    my $entry_page_count = $c->db->dbh->selectrow_array(
        q{SELECT COUNT(entry_id) FROM entry_page where entry_id=?},
        {},
        $entry_id
    );
    my $entry_page = $c->db->dbh->selectrow_hashref(
        q{SELECT * FROM entry_page WHERE entry_id=? AND page_no=?},
        {},
        $entry_id, $page_no,
    );
    unless ($entry_page) {
        warn "cannot get entry_page";
        return $c->res_404();
    }

    $c->render(
        'entry.mt',
        {
            entry            => $entry,
            entry_page       => $entry_page,
            entry_page_count => $entry_page_count,
        }
    );
}

1;
