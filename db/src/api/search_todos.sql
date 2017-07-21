
create or replace function search_items(query text) returns setof todos as $$
select * from todos where todo like query
$$ stable language sql;
