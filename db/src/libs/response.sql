drop schema if exists response cascade;
create schema response;
grant usage on schema response to public;


create or replace function response.get_cookie_string(name text, value text, expires_after int, path text) returns text as $$
    with vars as (
        select
            case
                when expires_after > 0 
                then current_timestamp + (expires_after::text||' seconds')::interval
                else timestamp 'epoch'
            end as expires_on
    )
    select 
        name ||'=' || value || '; ' ||
        'Expires=' || to_char(expires_on, 'Dy, DD Mon YYYY HH24:MI:SS GMT') || '; ' ||
        'Max-Age=' || expires_after::text || '; ' ||
        'Path=' ||path|| '; HttpOnly'
    from vars;
$$ stable language sql;

create or replace function response.set_header(name text, value text) returns void as $$
    select set_config(
        'response.headers', 
        jsonb_insert(
            (case coalesce(current_setting('response.headers',true),'')
            when '' then '[]'
            else current_setting('response.headers')
            end)::jsonb,
            '{0}'::text[], 
            jsonb_build_object(name, value))::text, 
        true
    );
$$ stable language sql;

create or replace function response.set_cookie(name text, value text, expires_after int, path text) returns void as $$
    select response.set_header('Set-Cookie', response.get_cookie_string(name, value, expires_after, path));
$$ stable language sql;

create or replace function response.delete_cookie(name text) returns void as $$
    select response.set_header('Set-Cookie', response.get_cookie_string(name, 'deleted', 0 ,'/'));
$$ stable language sql;