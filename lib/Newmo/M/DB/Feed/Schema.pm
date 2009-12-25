package Newmo::M::DB::Feed::Schema;
use strict;
use warnings;
use DBIx::Skinny::Schema;

install_table feed => schema {
    pk 'id';
    columns qw/
        id
        link
        title
    /;
};

install_table entry => schema {
    pk 'id';
    columns qw/
        id
        feed_id
        link
        title
        content
    /;
};

1;
