import {rest_service, jwt, resetdb} from '../common.js';
const request = require('supertest');
const should = require("should");

describe('search', function() {
  before(function(done){ resetdb(); done(); });

  it('basic', function(done) {
    rest_service()
      .post('/rpc/search_items')
      .set('Authorization', 'Bearer ' + jwt)
      .send({'query': '%item%'})
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.length.should.equal(4);
      })
  });

});
