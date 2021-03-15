create or replace function signup(name text, email text, password text) returns customer as $$
declare
    usr record;
    token text;
    cookie text;
    jwt_lifetime int;
    jwt_secret text;
begin
    jwt_lifetime := coalesce(current_setting('pgrst.jwt_lifetimet',true)::int, 3600);
    jwt_secret := coalesce(settings.get('jwt_secret'), current_setting('pgrst.jwt_secret',true));

    insert into data."user" as u
    (name, email, password) values ($1, $2, $3)
    returning *
   	into usr;

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
end
$$ security definer language plpgsql;

revoke all privileges on function signup(text, text, text) from public;
