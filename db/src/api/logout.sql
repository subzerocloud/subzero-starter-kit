create or replace function logout() returns customer as $$
declare
    cookie text;
begin
    cookie := util.get_cookie_string('SESSIONID', '', 0, '/');
    perform set_config('response.headers', '[{"Set-Cookie":"'||cookie||'"}]', true);

    return (null, null, null, null) :: customer;
end
$$ stable security definer language plpgsql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function logout() from public;