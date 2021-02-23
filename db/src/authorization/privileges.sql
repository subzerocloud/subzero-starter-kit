-- This file is a central place to define all the permissions for roles used by the application
-- You should write the sql in such a way that executing this file (even multiple times) will reset
-- all the roles to the correct permissions

-- the auto inclusion of this file when generating migrations is configured in .env file
-- with MIGRATION_INCLUDE_END variable

-- Resetting all privileges for application roles (start from a clean slate)
-- we use a convenience inline function here since PostgreSQL does not have a specific statement
-- you only need to list the roles and schemas that need to be reset
do $$
declare
    r text;
    s text;
    -- list roles which need resetting here
    role_list text[] = '{webuser, anonymous, api, proxy}';
    -- list schemas for which to reset privileges
    schema_list text[] = '{api, data, request, response, settings}';
begin
    foreach r in array role_list loop 
        foreach s in array schema_list loop 
            execute format('revoke all privileges on all tables    in schema %I from %I', s, r);
            execute format('revoke all privileges on all sequences in schema %I from %I', s, r);
            execute format('revoke all privileges on all functions in schema %I from %I', s, r);
            execute format('revoke all privileges on                  schema %I from %I', s, r);
        end loop;
    end loop;
end$$;

-- set the correct owner for all the api views
alter view
  api.todos
-- list all views here
-- , api.another_view
owner to api;


-- Loading roles privilege

-- specify which application roles can access this api (you'll probably list them all)
grant usage on schema request, response to public;
grant usage on schema api to anonymous, webuser, proxy;

-- set privileges to all the auth flow functions
grant execute on function api.login(text,text) to anonymous;
grant execute on function api.logout() to anonymous;
grant execute on function api.signup(text,text,text) to anonymous;
grant execute on function api.me() to webuser;
grant execute on function api.login(text,text) to webuser;
grant execute on function api.logout() to webuser;
grant execute on function api.refresh_token() to webuser;
grant execute on function api.on_oauth_login(text,json) to proxy;

-- define the who can access todo model data
-- define the RLS policy controlling what rows are visible to a particular application user
drop policy if exists todo_access_policy on data.todo;
create policy todo_access_policy on data.todo to api 
using (
    -- the authenticated users can see all his todo items
    -- notice how the rule changes based on the current user_id
    -- which is specific to each individual request
    (request.user_role() = 'webuser' and request.user_id() = owner_id)

    or
    -- everyone can see public todo
    (private = false)
)
with check (
    -- authenticated users can only update/delete their todos
    (request.user_role() = 'webuser' and request.user_id() = owner_id)
);


-- give access to the view owner to this table
grant select, insert, update, delete on data.todo to api;
grant usage on data.todo_id_seq to webuser;


-- While grants to the view owner and the RLS policy on the underlying table 
-- takes care of what rows the view can see, we still need to define what 
-- are the rights of our application user in regard to this api view.

-- authenticated users can request/change all the columns for this view
grant select, insert, update, delete on api.todos to webuser;

-- anonymous users can only request specific columns from this view
grant select (id, todo) on api.todos to anonymous;
-------------------------------------------------------------------------------
