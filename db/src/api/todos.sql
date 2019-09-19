-- define the view which is just selecting everything from the underlying table
-- although it looks like a user would see all the rows by looking just at this definition,
-- the RLS policy defined on the underlying table attached to the view owner (api)
-- will make sure only the appropriate roles will be revealed.
-- notice how for the api we don't expose the owner_id column even though it exists and is used
-- in the RLS policy, also, while out table name is "todo", singular, meant to symbolize a data type/model,
-- the view is named "todos", plural, to match the rest conventions.
create or replace view todos as
select id, todo, private, (owner_id = request.user_id()) as mine from data.todo t;


-- trigger function which inserts data in case of an update or insert statement on the view api.todos
-- into the underlying tables in schema data
create or replace function upsert_todos_row() returns trigger as $$
declare
    var_owner_id int;
begin
    if OLD.id is not null then
        update 
            data.todo
        set
            todo=NEW.todo,
            private=NEW.private
        where id=OLD.id
        returning id, private, todo, owner_id into NEW.id, NEW.private, NEW.todo, var_owner_id;
    else
        insert into data.todo 
            (todo, private, owner_id)
        values
            (NEW.todo, NEW.private :: bool, request.user_id())
        returning id, private, todo, owner_id into NEW.id, NEW.private, NEW.todo, var_owner_id;
    end if;

    if NEW.id is not null then
        return (NEW.id, NEW.todo, NEW.private :: bool, var_owner_id = request.user_id());
    else
        RAISE EXCEPTION 'updating dataset % did not succeed', OLD.id;
    end if;
end
$$ security definer language plpgsql;

-- enable trigger which overwrites insert and update actions of the view todos
create trigger upsert_todos instead of insert or update on todos
    for each row
        execute function upsert_todos_row();


-- trigger function which deletes data in case of an delete statement on the view api.todos
-- from the underlying table in schema data
create or replace function delete_todos_row() returns trigger as $$
declare
    result int;
begin
    
    with deleted as (delete from data.todo where id = OLD.id returning 1)
    select count(*) into result from deleted;

    if (result) then
        return OLD;
    else
        RAISE EXCEPTION 'deleting dataset % did not succeed', OLD.id;
    end if;
end
$$ security definer language plpgsql;

-- enable trigger which overwrites delete action of the view todos
create trigger delete_todos instead of delete on todos
    for each row
        execute function delete_todos_row();

alter view todos owner to api; -- it is important to set the correct owner to the RLS policy kicks in
alter function upsert_todos_row() owner to api;
alter function delete_todos_row() owner to api;
