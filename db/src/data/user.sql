create type user_role as enum ('webuser');
create table "user" (
	id                   serial primary key,
	name                 text not null,
	email                text not null unique,
	"password"           text not null,
	"role"               user_role not null default 'webuser',

	check (length(name)>2),
	check (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

create or replace function encrypt_pass() returns trigger as $$
begin
  if new.password is not null then
  	new.password = public.crypt(new.password, public.gen_salt('bf'));
  end if;
  return new;
end
$$ language plpgsql;

create trigger user_encrypt_pass_trigger
before insert or update on "user"
for each row
execute procedure encrypt_pass();
