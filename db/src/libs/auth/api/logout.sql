create or replace function logout() returns session as
    'SELECT (null :: json, null :: text) :: session'
stable security definer language sql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function logout() from public;