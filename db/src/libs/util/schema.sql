drop schema if exists util cascade;
create schema util;
grant usage on schema util to public;

create or replace function util.get_cookie_string(name text, value text, expires_after int, path text) returns text as $$
    select 
        name ||'=' || value || '; ' ||
        'Expires=' || to_char(current_timestamp + (expires_after::text||' seconds')::interval, 'Dy, DD Mon YYYY HH24:MI:SS GMT') || '; ' ||
        'Max-Age=' || expires_after::text || '; ' ||
        'Path=' ||path|| '; HttpOnly';
$$ stable language sql;