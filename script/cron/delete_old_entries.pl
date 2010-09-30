use strict;
use warnings;
use Newmo;

my $c = Newmo->bootstrap();

my ($last_entry_id) = $c->db->dbh->selectrow_array(q{SELECT entry_id FROM entry ORDER BY entry_id DESC LIMIT 1});
$c->db->dbh->do(q{DELETE FROM entry WHERE entry_id < ? - 10000}, {}, $last_entry_id);
# entry_page table is removed automatically by FOREING KEY.

