drop schema if exists api cascade;
create schema api;
set search_path = api, public;

-- this role will be used as the owner of the views in the api schema
-- it is needed for the definition of the RLS policies
drop role if exists api;
create role api;
grant api to current_user; -- this is a workaround for RDS where the master user does not have SUPERUSER priviliges  


-- our endpoints
create type customer as (id int, name text, email text, role text);
\ir login.sql
\ir logout.sql
\ir on_oauth_login.sql
\ir refresh_token.sql
\ir signup.sql
\ir me.sql
\ir todos.sql
\ir search_todos.sql
