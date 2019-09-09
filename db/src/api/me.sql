create or replace function me() returns customer as $$
declare
    usr record;
begin

    select * from data."user"
    where id = request.user_id()
    into usr;

    return (
        usr.id,
        usr.name,
        usr.email,
        usr.role::text
    );
end
$$ stable security definer language plpgsql;

revoke all privileges on function me() from public;
