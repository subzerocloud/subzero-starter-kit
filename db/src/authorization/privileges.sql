\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity ore move the permissions
-- to the file where you defined the entity

-- specify which application roles can access this api (you'll probably list them all)
grant usage on schema api to api, anonymous, webuser;
-- specify grants on schema data in order to manipulate data on original tables (maybe you'll also add anonymous)
grant usage on schema data to api;

-- set privileges to all the auth flow functions
grant execute on function api.login(text,text) to anonymous;
grant execute on function api.logout() to anonymous;
grant execute on function api.signup(text,text,text) to anonymous;
grant execute on function api.me() to webuser;
grant execute on function api.login(text,text) to webuser;
grant execute on function api.logout() to webuser;
grant execute on function api.refresh_token() to webuser;

-- define the who can access todo model data
-- enable RLS on the table holding the data
alter table data.todo enable row level security;
-- define the RLS policy controlling what rows are visible to a particular application user
create policy todo_access_policy_select on data.todo for select to api 
using (
	-- the authenticated users can see all his todo items
	-- notice how the rule changes based on the current user_id
	-- which is specific to each individual request
	(request.user_role() = 'webuser' and request.user_id() = owner_id)
	or
	-- everyone can see public todo
	(private = false)
	or
	(request.user_role() = 'webadmin')
);

-- insert, update and delete only own entries as webuser and everything as webadmin
create policy todo_access_policy on data.todo to api 
using (
	(request.user_role() = 'webuser' and request.user_id() = owner_id) or
	(request.user_role() = 'webadmin')
) with check (
	(request.user_role() = 'webuser' and request.user_id() = owner_id) or
	(request.user_role() = 'webadmin')
);

-- give access to the view owner to this table
grant select, insert, update, delete on data.todo to api;
grant usage on data.todo_id_seq to api;


-- While grants to the view owner and the RLS policy on the underlying table 
-- takes care of what rows the view can see, we still need to define what 
-- are the rights of our application user in regard to this api view.

-- authenticated users can request/change all the columns for this view
grant select, insert, update, delete on api.todos to webuser;

-- anonymous users can only request specific columns from this view
grant select (id, todo) on api.todos to anonymous;
-------------------------------------------------------------------------------
