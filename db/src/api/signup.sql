create or replace function signup(name text, email text, password text) returns customer as $$
declare
    usr record;
    token text;
    cookie text;
begin
    insert into data."user" as u
    (name, email, password) values ($1, $2, $3)
    returning *
   	into usr;

    token := pgjwt.sign(
        json_build_object(
            'role', usr.role,
            'user_id', usr.id,
            'exp', extract(epoch from now())::integer + settings.get('jwt_lifetime')::int
        ),
        settings.get('jwt_secret')
    );
    cookie := util.get_cookie_string('SESSIONID', token, settings.get('jwt_lifetime')::int,'/');
    perform set_config('response.headers', '[{"Set-Cookie":"'||cookie||'"}]', true);

     return (
        usr.id,
        usr.name,
        usr.email,
        usr.role::text
    );
end
$$ security definer language plpgsql;

revoke all privileges on function signup(text, text, text) from public;
