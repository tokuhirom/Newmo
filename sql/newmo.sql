create table feed (
    feed_id integer primary key autoincrement,
    link text not null,
    title varchar(255),
    unique (link)
);

create table entry (
    entry_id integer primary key autoincrement,
    feed_id integer not null,
    link text not null unique,
    title varchar(255),
    content text,
    hatenabookmark_users integer default 0,
    issued integer,
    modified integer
);
create index feed_id on entry (feed_id);

create table entry_page (
    entry_page_id integer primary key autoincrement,
    entry_id integer not null,
    page_no integer not null,
    body text
);
create unique index entry_id_page_no on entry_page (entry_id, page_no);

