# subZero GraphQL/REST API Starter Kit

Base project and tooling for authoring **data API**
backends with [subZero](https://subzero.cloud/).

![subZero Starter Kit](https://raw.githubusercontent.com/wiki/subzerocloud/postgrest-starter-kit/images/postgrest-starter-kit.gif "subZero Starter Kit")


## Runs Anywhere
Run subZero stack as a hassle-free service ([free plan](https://subzero.cloud/pricing.html) available) or deploy it yourself anywhere using binary and docker distributions.

## Features

✓ Out of the box GraphQL/REST endpoints created by reflection over a PostgreSQL schema<br>
✓ Cross-platform development on macOS, Windows or Linux inside [Docker](https://www.docker.com/)<br>
✓ [PostgreSQL](https://www.postgresql.org/) database schema boilerplate with authentication and authorization flow<br>
✓ [OpenResty](https://openresty.org/en/) configuration files for the reverse proxy<br>
✓ [RabbitMQ](https://www.rabbitmq.com/) integration through [pg-amqp-bridge](https://github.com/subzerocloud/pg-amqp-bridge)<br>
(https://www.rabbitmq.com/web-stomp.html)<br>
✓ [Lua](https://www.lua.org/) functions to hook into each stage of the HTTP request and add custom logic (integrate 3rd party systems)<br>
✓ Debugging and live code reloading (sql/configs/lua) functionality using [subzero-cli](https://github.com/subzerocloud/subzero-cli)<br>
✓ Full migration management (migration files are automatically created) through [subzero-cli](https://github.com/subzerocloud/subzero-cli)/[sqitch](http://sqitch.org/)/[apgdiff](https://github.com/subzerocloud/apgdiff)<br>
✓ SQL unit test using [pgTAP](http://pgtap.org/)<br>
✓ Integration tests with [SuperTest / Mocha](https://github.com/visionmedia/supertest)<br>
✓ Docker files for building production images<br>
✓ Community support on [Slack](https://slack.subzero.cloud/)<br>
✓ Custom PostgREST binary that creates prepared statements instead of inline queries<br>
✓ Live events (with authentication/authorization) through RabbitMQ [WebSTOMP plugin](https://www.rabbitmq.com/web-stomp.html)<br>
✓ Scriptable proxy level caching using nginx [proxy_cache](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache) (other backends like Redits possible)<br>

## Directory Layout

```bash
.
├── db                        # Database schema source files and tests
│   └── src                   # Schema definition
│       ├── api               # Api entities avaiable as REST endpoints
│       ├── data              # Definition of source tables that hold the data
│       ├── libs              # A collection modules of used throughout the code
│       ├── authorization     # Application level roles and their privileges
│       ├── sample_data       # A few sample rows
│       └── init.sql          # Schema definition entry point
├── openresty                 # Reverse proxy configurations and Lua code
│   ├── lualib
│   │   └── user_code         # Application Lua code
│   ├── nginx                 # Nginx files
│   │   ├── conf              # Configuration files
│   │   └── html              # Static frontend files
│   ├── Dockerfile            # Dockerfile definition for production
│   └── entrypoint.sh         # Custom entrypoint
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
* [subZero CLI](https://github.com/subzerocloud/subzero-cli#install)

### Create a New Project
subzero-cli provides you with a `base-project` command that lets you create a new project structure:

```bash
subzero base-project

? Enter the directory path where you want to create the project .
? Choose the starter kit (Use arrow keys)
❯ subzero-starter-kit (REST & GraphQL) 
  postgrest-starter-kit (REST) 
```

After the files have been created, you can bring up your application (API).
In the root folder of application, run the docker-compose command

```bash
docker-compose up -d
```

The API server will become available at the following endpoints:

- REST [http://localhost:8080/rest/](http://localhost:8080/rest/)
- GraphiQL IDE [http://localhost:8080/graphiql/](http://localhost:8080/graphiql/)
- GraphQL Simple Schema [http://localhost:8080/graphql/simple/](http://localhost:8080/graphql/simple/)
- GraphQL Relay Schema [http://localhost:8080/graphql/relay/](http://localhost:8080/graphql/relay/)

Try a simple request

```bash
curl http://localhost:8080/rest/todos?select=id,todo
```

Try a GraphQL query in the integrated GraphiQL IDE at [http://localhost:8080/graphiql/](http://localhost:8080/graphiql/)

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
if you edit a sql/conf/lua file in your project, the changes will immediately be applied.


## Testing

The starter kit comes with a testing infrastructure setup.
You can write pgTAP tests that run directly in your database, useful for testing the logic that resides in your database (user privileges, Row Level Security, stored procedures).
Integration tests are written in JavaScript.

Here is how you run them

```bash
npm install                     # Install test dependencies
npm test                        # Run all tests (db, rest, graphql)
npm run test_db                 # Run pgTAP tests
npm run test_rest               # Run rest integration tests
npm run test_graphql            # Run graphql integration tests
```

## Deployment
* [subZero Cloud](http://docs.subzero.cloud/production-infrastructure/subzero-cloud/)
* [Amazon ECS+RDS](http://docs.subzero.cloud/production-infrastructure/aws-ecs-rds/)
* [Amazon Fargate+RDS](http://docs.subzero.cloud/production-infrastructure/aws-fargate-rds/)
* [Dedicated Linux Server](https://docs.subzero.cloud/production-infrastructure/ubuntu-server/)

## Contributing

Anyone and everyone is welcome to contribute.

## Support and Documentation
* [Documentation](https://docs.subzero.cloud)
* [PostgREST API Referance](https://postgrest.com/en/stable/api.html)
* [PostgreSQL Manual](https://www.postgresql.org/docs/current/static/index.html)
* [Slack](https://slack.subzero.cloud/) — Watch announcements, share ideas and feedback
* [GitHub Issues](https://github.com/subzerocloud/subzero-starter-kit/issues) — Check open issues, send feature requests

## License

Copyright © 2017-present subZero Cloud, LLC.<br />
This source code in this repository is licensed under [MIT](https://github.com/subzerocloud/subzero-starter-kit/blob/master/LICENSE.txt) license<br />
Components implementing the GraphQL interface (customized PostgREST and OpenResty docker images) are available under a [commercial license](https://subzero.cloud)<br />
The documentation to the project is licensed under the [CC BY-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/) license.

