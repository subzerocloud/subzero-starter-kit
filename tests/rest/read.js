import {rest_service, jwt, resetdb} from '../common.js';
const request = require('supertest');
const should = require("should");

describe('read', function() {
  before(function(done){ resetdb(); done(); });
  
  it('basic', function(done) {
    rest_service()
      .get('/todos?select=id,todo')
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.length.should.equal(3);
      })
  });

  it('by primary key', function(done) {
    rest_service()
      .get('/todos/1?select=id,todo')
      .expect(200, done)
      .expect( r => {
        r.body.todo.should.equal('item_1');
      })
  });

});
