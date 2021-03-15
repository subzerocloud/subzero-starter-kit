create or replace function on_oauth_login(provider text, profile json) returns void as $$
declare
    usr record;
    _email text;
    _name text;
    token text;
    jwt_lifetime int;
    jwt_secret text;
begin
    jwt_lifetime := coalesce(current_setting('pgrst.jwt_lifetimet',true)::int, 3600);
    jwt_secret := coalesce(settings.get('jwt_secret'), current_setting('pgrst.jwt_secret',true));

    -- check the jwt (generated in the proxy) is authorized to perform oauth logins
    if request.jwt_claim('oauth_login') != 'true' then
        raise exception 'unauthorized';
    end if;

    -- depending on oauth provider, extract needed information
    case provider
        when 'google'   then
            _email := profile->>'email';
            _name  := profile->>'name';
        when 'facebook' then
            _email := coalesce(profile->>'email', profile->>'id' || '@facebook.com');
            _name  := profile->>'name';
        when 'github'   then
            _email := profile->>'email';
            _name  := profile->>'name';
        else
            raise exception 'unknown oauth provider';
    end case;

    -- upsert the user to our database, we set the password to something random since the user will be using only the oauth login
    insert into data."user" as u
    (name, email, password) values (_name, _email, gen_random_uuid())
    on conflict (email) do nothing
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

    -- set the session cookie and redirect to /
    perform response.set_cookie('SESSIONID', token, jwt_lifetime, '/');
    perform response.set_header('location', '/');
    perform set_config('response.status', '303', true);
end
$$ security definer language plpgsql;
-- by default all functions are accessible to the public, we need to remove that and define our specific access rules
revoke all privileges on function on_oauth_login(text, json) from public;