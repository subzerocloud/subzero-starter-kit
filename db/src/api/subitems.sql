create or replace view api.subitems as
select data.subitems.relay_id as id, id as row_id,  name, item_id, (owner_id = request.user_id()) as mine from data.subitems;
alter view api.subitems owner to api;