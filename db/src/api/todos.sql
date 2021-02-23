-- define the view which is just selecting everything from the underlying table
-- although it looks like a user would see all the rows by looking just at this definition,
-- the RLS policy defined on the underlying table attached to the view owner (api)
-- will make sure only the appropriate roles will be revealed.
-- notice how for the api we don't expose the owner_id column even though it exists and is used
-- in the RLS policy, also, while our table name is "todo", singular, meant to symbolize a data type/model,
-- the view is named "todos", plural, to match the rest conventions.

create or replace view todos as
select id, todo, private, (owner_id = request.user_id()) as mine
from data.todo;

-- note that the owner of this view is set to "api" (check authorization/privileges.sql)
-- this is an important step in order to have table RLS interact correctly with views
-- you'll need to set the correct owner for every view in the api schema in order for the RLS
-- on the underlying tables to be applied



