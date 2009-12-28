package Newmo::M::DB::Feed::Schema;
use strict;
use warnings;
use DBIx::Skinny::Schema;

install_table feed => schema {
    pk 'feed_id';
    columns qw/
        feed_id
        link
        title
    /;
};

install_table entry => schema {
    pk 'entry_id';
    columns qw/
        entry_id
        feed_id
        link
        title
        content
        hatenabookmark_users
    /;
};

install_table entry_page => schema {
    pk 'entry_page_id';
    columns qw/
        entry_page_id
        entry_id
        page_no
        body
    /;
};

1;
