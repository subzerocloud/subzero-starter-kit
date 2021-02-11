const jsonwebtoken = require('jsonwebtoken');
const request = require('supertest');
const { config } = require('dotenv');
const { spawnSync } = require('child_process');

config()// .env file vars added to process.env

const COMPOSE_PROJECT_NAME = process.env.COMPOSE_PROJECT_NAME
const POSTGRES_USER = process.env.POSTGRES_USER
const POSTGRES_PASSWORD = process.env.POSTGRES_PASSWORD
const SUPER_USER = process.env.SUPER_USER
const SUPER_USER_PASSWORD = process.env.SUPER_USER_PASSWORD

const DB_HOST = process.env.DB_HOST
const DB_NAME = process.env.DB_NAME
const PG = `db`

const psql_version = spawnSync('psql', ['--version'])
const have_psql = (psql_version.stdout && psql_version.stdout.toString('utf8').trim().length > 0)

exports.rest_service =  () => {
  return request(process.env.SERVER_PROXY_URI)
}

exports.graphql_simple = () => { 
  return request(process.env.SERVER_PROXY_URI.replace('rest', 'graphql/simple' ))
            .post('/')
            .set('Accept', 'application/json');
}

exports.graphql_relay = () => { 
  return request(process.env.SERVER_PROXY_URI.replace('rest', 'graphql/relay' ))
            .post('/')
            .set('Accept', 'application/json');
}

exports.resetdb = () => {
  let pg
  if (have_psql) {
    var env = Object.create(process.env)
    env.PGPASSWORD = SUPER_USER_PASSWORD
    pg = spawnSync('psql', ['-h', 'localhost', '-U', SUPER_USER, DB_NAME, '-f', process.env.PWD + '/db/src/sample_data/reset.sql'], { env: env })
  } else {
    pg = spawnSync('docker', ['exec', PG, 'psql', '-U', SUPER_USER, DB_NAME, '-f', 'docker-entrypoint-initdb.d/sample_data/reset.sql'])
  }
  if (pg.status !== 0) {
    throw new Error(`Could not reset database in rest tests. Error = ${pg.stderr.toString()}`)
  }
}


request.Test.prototype.withRole = function (role) {
  if (typeof role !== 'string') {
    throw new TypeError(`The role must be given as a string`)
  }

  let payload = {
    user_id: 1,
    role,
    // Pretend that the JWT was issued 30 seconds ago in the past
    iat: Math.floor(Date.now() / 1000) - 30
  }

  let jwt = jsonwebtoken.sign(payload, process.env.JWT_SECRET)

  return this.set('Authorization', `Bearer ${jwt}`)
}
