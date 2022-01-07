-- some setting to make the output less verbose
\set QUIET on
\set ON_ERROR_STOP on
set client_min_messages to warning;

-- load some variables from the env
\setenv base_dir :DIR
\set base_dir `if [ $base_dir != ":"DIR ]; then echo $base_dir; else echo "/docker-entrypoint-initdb.d"; fi`
\set anonymous `echo $DB_ANON_ROLE`
\set authenticator `echo $DB_USER`
\set authenticator_pass `echo $DB_PASS`
\set jwt_secret `echo $JWT_SECRET`
\set quoted_jwt_secret '\'' :jwt_secret '\''

\echo # Loading database definition
begin;
create extension if not exists pgcrypto;

\echo # Loading helper libs

-- functions for storing different settins in a table
\ir libs/settings.sql

-- functions for reading different http request properties exposed by PostgREST
\ir libs/request.sql

-- functions for for setting response headers and cookies
\ir libs/response.sql

-- functions for JWT token generation in the database context
\ir libs/pgjwt.sql

-- functions that will trigger schema cache reload
\ir libs/postgrest.sql


\echo # Loading application definitions

-- private schema where all tables will be defined
-- you can use othere names besides "data" or even spread the tables
-- between different schemas. The schema name "data" is just a convention
\ir data/schema.sql

-- entities inside this schema (which should be only views and stored procedures) will be 
-- exposed as API endpoints. Access to them however is still governed by the 
-- privileges defined for the current PostgreSQL role making the requests
\ir api/schema.sql


\echo # Loading roles and privilege settings
\ir authorization/roles.sql
\ir authorization/privileges.sql

select settings.set('jwt_secret', :quoted_jwt_secret);
select settings.set('jwt_lifetimet', '3600');
-- alter role usually does nto work in cloud databases
-- alter role :"authenticator" set pgrst.jwt_lifetimet = '3600';
-- alter role :"authenticator" set pgrst.jwt_secret = :quoted_jwt_secret;

\echo # Loading sample data
\ir sample_data/data.sql


commit;
\echo # ==========================================
