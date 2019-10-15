
create or replace function logout() returns void as $$
begin
    perform response.delete_cookie('SESSIONID');
end
$$ security definer language plpgsql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function logout() from public;