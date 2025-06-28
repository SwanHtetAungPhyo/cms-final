create table cms_whole_sys_role
(
    role_id   uuid default gen_random_uuid() not null
        primary key,
    role_name role_type                      not null
        constraint uq_role_name
            unique
);

alter table cms_whole_sys_role
    owner to "CMS_AUTH_owner";

create index idx_role_id
    on cms_whole_sys_role using hash (role_id);

create table cms_user
(
    cms_user_id      uuid      default gen_random_uuid() not null
        primary key,
    cms_user_name    varchar(100)                        not null,
    cms_user_email   varchar(150)                        not null
        unique,
    cms_name_space   varchar(100),
    password         varchar(90)                         not null,
    cms_user_role_id uuid                                not null
        constraint fk_cms_user_role
            references cms_whole_sys_role
            on delete cascade,
    verified         boolean   default false,
    created_at       timestamp default CURRENT_TIMESTAMP,
    updated_at       timestamp default CURRENT_TIMESTAMP
);

alter table cms_user
    owner to "CMS_AUTH_owner";

create index idx_cms_user_email
    on cms_user using hash (cms_user_email);

create index idx_cms_user_id
    on cms_user using hash (cms_user_id);

create index idx_cms_user_role
    on cms_user (cms_user_role_id);

create table cms_cus_purchase
(
    relation_id   uuid      default gen_random_uuid() not null
        primary key,
    cms_cus_id    uuid                                not null
        constraint fk_cms_purchase_user
            references cms_user
            on delete cascade,
    system_name   system_type                         not null,
    purchase_date timestamp default CURRENT_TIMESTAMP not null,
    created_at    timestamp default CURRENT_TIMESTAMP
);

alter table cms_cus_purchase
    owner to "CMS_AUTH_owner";

create index idx_purchase_user
    on cms_cus_purchase (cms_cus_id);

create index idx_purchase_date
    on cms_cus_purchase (purchase_date);

create index idx_purchase_system
    on cms_cus_purchase using hash (system_name);


