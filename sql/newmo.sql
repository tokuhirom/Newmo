create table feed (
    id integer primary key autoincrement,
    link text not null,
    title varchar(255),
    unique (link)
);

create table entry (
    id integer primary key autoincrement,
    feed_id integer not null,
    link text not null unique,
    title varchar(255),
    content text,
    issued integer,
    modified integer
);
create index feed_id on entry (feed_id);

