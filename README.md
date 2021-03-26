# subZero GraphQL/REST API Starter Kit

Base project and tooling for authoring **data API**
backends with [subZero](https://subzero.cloud/).

## Runs Anywhere
Run subZero stack as a hassle-free service ([free plan](https://subzero.cloud/pricing.html) available) or deploy it yourself anywhere using binary and docker distributions.

## Features

✓ Out of the box GraphQL/REST endpoints created by reflection over a PostgreSQL schema<br>
✓ Authentication using email/password or using 3rd party OAuth 2.0 providers (google/facebook/github preconfigured) <br>
✓ Uses [PostgREST+](https://subzero.cloud/postgrest-plus.html) with features like aggregate functions (group by), window functions, SSL, HTTP2, custom relations<br>
✓ Cross-platform development on macOS, Windows or Linux inside [Docker](https://www.docker.com/)<br>
✓ [PostgreSQL](https://www.postgresql.org/) database schema boilerplate with authentication and authorization flow<br>
✓ Debugging and live code reloading (sql/configs/lua) functionality using [subzero-cli](https://github.com/subzerocloud/subzero-cli)<br>
✓ Full migration management (migration files are automatically created) through [subzero-cli](https://github.com/subzerocloud/subzero-cli)<br>
✓ SQL unit test using [pgTAP](http://pgtap.org/)<br>
✓ Integration tests with [SuperTest / Mocha](https://github.com/visionmedia/supertest)<br>
✓ Community support on [Slack](https://slack.subzero.cloud/)<br>

✓ Scriptable proxy level caching using nginx [proxy_cache](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache) or Redis<br>

## Directory Layout

```bash
.
├── db                        # Database schema source files and tests
│   └── src                   # Schema definition
│       ├── api               # Api entities available as REST and GraphQL endpoints
│       ├── data              # Definition of source tables that hold the data
│       ├── libs              # A collection of modules used throughout the code
│       ├── authorization     # Application level roles and their privileges
│       ├── sample_data       # A few sample rows
│       └── init.sql          # Schema definition entry point
├── html                      # Place your static frontend files here
├── tests                     # Tests for all the components
│   ├── db                    # pgTap tests for the db
│   ├── graphql               # GraphQL interface tests
│   └── rest                  # REST interface tests
├── docker-compose.yml        # Defines Docker services, networks and volumes
└── .env                      # Project configurations

```



## Installation 

### Prerequisites
* [Docker](https://www.docker.com)
* [Node.js](https://nodejs.org/en/)
* [subzero-cli](https://github.com/subzerocloud/subzero-cli#install)

### Create a New Project
Click **[Use this template]** (green) button.
Choose the name of your new repository, description and public/private state then click **[Create repository from template]** button.
Check out the [step by step guide](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template) if you encounter any problems.

After this, clone the newly created repository to your computer.
In the root folder of application, run the docker-compose command

```bash
docker-compose up -d
```

The API server will become available at the following endpoints:

- Frontend [http://localhost:8080/](http://localhost:8080/)
- REST [http://localhost:8080/rest/](http://localhost:8080/rest/)
- GraphQL Simple Schema [http://localhost:8080/graphql/simple/](http://localhost:8080/graphql/simple/)
- GraphQL Relay Schema [http://localhost:8080/graphql/relay/](http://localhost:8080/graphql/relay/)

Try a simple request

```bash
curl http://localhost:8080/rest/todos?select=id,todo
```

Try a GraphQL query in the integrated [GraphiQL IDE](http://localhost:8080/explore/graphql.html)

```
{
  todos{
    id
    todo
  }
}
```

## Development workflow and debugging

Execute `subzero dashboard` in the root of your project.<br />
After this step you can view the logs of all the stack components (SQL queries will also be logged) and
if you edit a sql/conf file in your project, the changes will immediately be applied.


## Unit and integration tests

The starter kit comes with a testing infrastructure setup.
You can write pgTAP tests that run directly in your database, useful for testing the logic that resides in your database (user privileges, Row Level Security, stored procedures).
Integration tests are written in JavaScript.

Here is how you run them locally

```bash
yarn install         # Install test dependencies
yarn test            # Run all tests (db, rest, graphql)
yarn test_db         # Run pgTAP tests
yarn test_rest       # Run rest integration tests
yarn test_graphql    # Run graphql integration tests
```

All the test are also executed on on git push (on GitHub) 

## Deployment
The deployment is done using a [GitHub Actions script](.github/workflows/test_deploy.yaml).
The deploy action will push your migrations to the production database using sqitch and the static files with scp.
The deploy step is triggered only on git tags in the form of `v1.2`

Note that the deploy action pushes to production the database migrations (db/migrations/) not the current database schema definition (db/src/) so you'll need execute `subzero migrations init --with-roles` before the first deploy and when iterating, you'll create new migrations using `subzero migration add <migration_name>`

You'll also need to configure the following "secrets" for your github deploy action
```
SUBZERO_EMAIL
SUBZERO_PASSWORD
APP_DOMAIN
APP_DB_HOST
APP_DB_PORT
APP_DB_NAME
APP_DB_MASTER_USER
APP_DB_MASTER_PASSWORD
APP_DB_AUTHENTICATOR_USER
APP_DB_AUTHENTICATOR_PASSWORD
APP_JWT_SECRET
```

While the deploy action is written for subzero.cloud (`DEPLOY_TARGET: subzerocloud`) it can easily be adapted for other deploy targets that run the subzero stack

## Contributing

Anyone and everyone is welcome to contribute.

## Support and Documentation
* [subZero Documentation](https://docs.subzero.cloud)
* [PostgREST API Referance](https://postgrest.com/en/stable/api.html)
* [PostgreSQL Manual](https://www.postgresql.org/docs/current/static/index.html)
* [Slack](https://slack.subzero.cloud/) — Watch announcements, share ideas and feedback
* [GitHub Issues](https://github.com/subzerocloud/subzero-starter-kit/issues) — Check open issues, send feature requests

## License

Copyright © 2017-2021 subZero Cloud, LLC.<br />
This source code in this repository is licensed under [MIT](https://github.com/subzerocloud/subzero-starter-kit/blob/master/LICENSE.txt) license<br />
Components implementing the GraphQL interface (customized PostgREST+ and OpenResty docker images) are available under a [commercial license](https://subzero.cloud)<br />
The documentation to the project is licensed under the [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/) license.

