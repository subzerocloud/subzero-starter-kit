create or replace function login(email text, password text) returns customer as $$
declare
    usr record;
    token text;
    jwt_lifetime int;
    jwt_secret text;
begin
    jwt_lifetime := coalesce(current_setting('pgrst.jwt_lifetimet',true)::int, 3600);
    jwt_secret := coalesce(settings.get('jwt_secret'), current_setting('pgrst.jwt_secret',true));

    select * from data."user" as u
    where u.email = $1 and u.password = public.crypt($2, u.password)
    into usr;

    if usr is NULL then
        raise exception 'invalid email/password';
    else
        token := pgjwt.sign(
            json_build_object(
                'role', usr.role,
                'user_id', usr.id,
                'exp', extract(epoch from now())::integer + jwt_lifetime
            ),
            jwt_secret
        );
        perform response.set_cookie('SESSIONID', token, jwt_lifetime, '/');
        return (
            usr.id,
            usr.name,
            usr.email,
            usr.role::text
        );
    end if;
end
$$ security definer language plpgsql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function login(text, text) from public;