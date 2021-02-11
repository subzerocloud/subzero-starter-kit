create or replace function refresh_token() returns boolean as $$
declare
    usr record;
    token text;
    cookie text;
begin

    select * from data."user" as u
    where id = request.user_id()
    into usr;

    if usr is null then
        raise exception 'user not found';
    else
        token := pgjwt.sign(
            json_build_object(
                'role', usr.role,
                'user_id', usr.id,
                'exp', extract(epoch from now())::integer + current_setting('pgrst.jwt_lifetimet',true)::int
            ),
            current_setting('pgrst.jwt_secret',true)
        );
        perform response.set_cookie('SESSIONID', token, current_setting('pgrst.jwt_lifetimet',true)::int,'/');
        return true;
    end if;
end
$$ stable security definer language plpgsql;

-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function refresh_token() from public;
