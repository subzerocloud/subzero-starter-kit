
create or replace function api.search_items(query text) returns setof api.items as $$
select * from api.items where name like query
$$ stable language sql;
