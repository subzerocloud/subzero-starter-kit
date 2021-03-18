drop schema if exists postgrest cascade;
create schema postgrest;

create or replace function postgrest.refresh_schema_cache() returns event_trigger as $$
begin
  notify pgrst, '';
end;
$$ language plpgsql;

create event trigger postgrest_refresh_schema_cache on ddl_command_end
    execute procedure postgrest.refresh_schema_cache();