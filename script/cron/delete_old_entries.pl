use strict;
use warnings;
use Newmo;

my $conffname = shift @ARGV;
my $conf = do $conffname or die "cannot load configuration file: $conffname";
my $c = Newmo->bootstrap(config => $conf);

my ($last_entry_id) = $c->db->dbh->selectrow_array(q{SELECT entry_id FROM entry ORDER BY entry_id DESC LIMIT 1});
$c->db->dbh->do(q{DELETE FROM entry WHERE entry_id < ? - 10000}, {}, $last_entry_id);
# entry_page table is removed automatically by FOREING KEY.

