
create or replace function login(email text, password text) returns customer as $$
declare
    usr record;
    token text;
begin

	select * from data."user" as u
    where u.email = $1 and u.password = public.crypt($2, u.password)
   	INTO usr;

    if usr is NULL then
        raise exception 'invalid email/password';
    else
        token := pgjwt.sign(
            json_build_object(
                'role', usr.role,
                'user_id', usr.id,
                'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int -- token expires in 1 hour
            ),
            settings.get('jwt_secret')
        );
        perform response.set_cookie('SESSIONID', token, settings.get('jwt_lifetime')::int,'/');
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