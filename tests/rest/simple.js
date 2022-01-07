const {rest_service} = require('../common.js');

describe('root endpoint', function () {
  it('returns json', function (done) {
    rest_service()
      .get('/')
      .expect('Content-Type', /json/)
      .expect(200, done)
  })
})
