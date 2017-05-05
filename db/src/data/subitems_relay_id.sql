create or replace function relay_id(data.subitems) returns text as $$
select encode(convert_to('item:' || $1.id::text, 'utf-8'), 'base64')
$$ immutable language sql;
create index on data.subitems (relay_id(data.subitems.*));
