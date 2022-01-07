begin;
select * from no_plan();

select * from check_test(
    views_are('api', array['todos'], 'tables present' ),
    true,
    'all views are present in api schema',
    'tables present',
    ''
);

select * from check_test(
    functions_are('api', array['login', 'logout', 'signup', 'refresh_token', 'on_oauth_login', 'me', 'search_items'], 'functions present' ),
    true,
    'all functions are present in api schema',
    'functions present',
    ''
);

select * from finish();
rollback;
