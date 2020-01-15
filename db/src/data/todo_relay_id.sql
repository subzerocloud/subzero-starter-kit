create or replace function relay_id(todo) returns text as $$
select encode(convert_to('todo:' || $1.id::text, 'utf-8'), 'base64')
$$ immutable language sql;
create index on todo (relay_id(todo.*));