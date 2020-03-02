-- define the view which is just selecting everything from the underlying table
-- although it looks like a user would see all the rows by looking just at this definition,
-- the RLS policy defined on the underlying table attached to the view owner (api)
-- will make sure only the appropriate roles will be revealed.
-- notice how for the api we don't expose the owner_id column even though it exists and is used
-- in the RLS policy, also, while out table name is "todo", singular, meant to symbolize a data type/model,
-- the view is named "todos", plural, to match the rest conventions.
create or replace view todos as
select data.relay_id(t.*) as id, id as row_id, todo, private, (owner_id = request.user_id()) as mine from data.todo t;

alter view todos owner to api; -- it is important to set the correct owner to the RLS policy kicks in

create or replace function data.mutation_todos() returns trigger as
$$
declare
    res api.todos;
begin
    if (tg_op = 'DELETE') then
        -- do nothing
        return new;
    elsif (tg_op = 'UPDATE') then
        update data.todo
        set "todo" = new."todo"
        where id = new.id;
        return new;
    elsif (tg_op = 'INSERT') then
        with gen as (insert into data.todo (todo, private)
            values (new.todo, new.private)
            returning *)
        select gen.id
        from gen
        into res;
        return res;
    end if;
end;
$$ security definer language plpgsql;

create trigger todos_write
    instead of insert or update or delete
    on todos
for each row execute procedure data.mutation_todos();
