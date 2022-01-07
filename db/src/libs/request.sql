drop schema if exists request cascade;
create schema request;

create or replace function request.env_var(v text) returns text as $$
    select current_setting(v, true);
$$ stable language sql;

create or replace function request.jwt_claim(c text) returns text as $$
    select current_setting('request.jwt.claim.' || c, true);
$$ stable language sql;

create or replace function request.cookie(c text) returns text as $$
    select current_setting('request.cookie.' || c, true);
$$ stable language sql;

create or replace function request.header(h text) returns text as $$
    select current_setting('request.header.' || h, true);
$$ stable language sql;

create or replace function request.user_id() returns int as $$
    select 
    case coalesce(current_setting('request.jwt.claim.user_id', true),'')
    when '' then 0
    else current_setting('request.jwt.claim.user_id', true)::int
	end
$$ stable language sql;

create or replace function request.user_role() returns text as $$
    select current_setting('request.jwt.claim.role', true)::text;
$$ stable language sql;

create or replace function request.validate(
  valid boolean, 
  err text,
  details text default '',
  hint text default '',
  errcode text default 'P0001'
) returns boolean as $$
begin
   if valid then
      return true;
   else
      RAISE EXCEPTION '%', err USING
      DETAIL = details, 
      HINT = hint, 
      ERRCODE = errcode;
   end if;
end
$$ stable language plpgsql;
