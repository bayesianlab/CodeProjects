


create table IF NOT EXISTS users (
    id serial primary key,
    email varchar(255) not null,
    created_at timestamp default current_timestamp
);
 