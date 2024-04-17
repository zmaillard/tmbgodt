CREATE TABLE album_type
(
    id   integer not null
        constraint album_type_pk
            primary key autoincrement,
    name TEXT    not null
);
CREATE TABLE IF NOT EXISTS "album"
(
    name          TEXT    not null,
    year          integer not null,
    id            integer not null
        constraint album_pk
            primary key autoincrement,
    album_type_id integer not null
        constraint album_album_type_id_fk
            references album_type
);
CREATE TABLE IF NOT EXISTS "song"
(
    day     integer not null
        constraint song_pk
            primary key,
    name    text    not null,
    albumId integer not null
        constraint song_album_id_fk
            references album
);
CREATE TABLE IF NOT EXISTS "schema_migrations" (version varchar(128) primary key);
-- Dbmate schema migrations
