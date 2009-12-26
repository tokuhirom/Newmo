create table feed (
    feed_id integer primary key autoincrement,
    link text not null,
    title varchar(255),
    unique (link)
);

create table entry (
    entry_id integer primary key autoincrement,
    feed_id integer not null,
    link text not null,
    title varchar(255),
    content text,
    hatenabookmark_users integer default 0,
    issued integer,
    modified integer
);
create unique index feed_link on entry (feed_id, link);

create table entry_page (
    entry_page_id integer primary key autoincrement,
    entry_id integer not null,
    page_no integer not null,
    body text
);
create unique index entry_id_page_no on entry_page (entry_id, page_no);

