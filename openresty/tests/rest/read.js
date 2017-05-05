import {rest_service, jwt, resetdb} from '../common.js';
const request = require('supertest');
const should = require("should");

describe('read', function() {
  after(function(done){ resetdb(); done(); });
  
  it('basic', function(done) {
    rest_service()
      .get('/items?row_id=eq.1')
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.length.should.equal(1);
        r.body[0].row_id.should.equal(1);
      })
  });

  it('by primary key', function(done) {
    rest_service()
      .get('/items/1?select=row_id,name')
      .expect(200, done)
      .expect( r => {
        r.body.row_id.should.equal(1);
        r.body.name.should.equal('item_1');
      })
  });

});