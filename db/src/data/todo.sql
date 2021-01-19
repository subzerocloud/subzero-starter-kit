create table todo (
	id    serial primary key,
	todo  text not null,
	private boolean default true,
	owner_id int references "user"(id) default request.user_id()
);
-- enable RLS on the table holding the data
alter table todo enable row level security;