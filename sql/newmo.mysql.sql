create table feed (
    feed_id int primary key auto_increment,
    link text not null,
    title varchar(255),
    unique (link(255))
) engine=innodb charset=utf8;

create table entry (
    entry_id int primary key auto_increment,
    feed_id int not null,
    link text not null,
    title varchar(255),
    content text,
    hatenabookmark_users int default 0,
    issued int,
    modified int
) engine=innodb charset=utf8;
create unique index feed_link on entry (feed_id, link(255));
alter table entry add index (feed_id, entry_id);

create table entry_page (
    entry_page_id int primary key auto_increment,
    entry_id int not null,
    page_no int not null,
    body text
) engine=innodb charset=utf8;
create unique index entry_id_page_no on entry_page (entry_id, page_no);
ALTER TABLE entry_page ADD FOREIGN KEY (entry_id) REFERENCES entry(entry_id) ON DELETE CASCADE;

