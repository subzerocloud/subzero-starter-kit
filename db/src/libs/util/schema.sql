drop schema if exists util cascade;
create schema util;
grant usage on schema util to public;

create or replace function util.get_cookie_string(name text, value text, expires_after int, path text) returns text as $$
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