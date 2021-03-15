require('should');
const {rest_service, resetdb} = require('../common.js');

describe('read', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

  it('basic', function (done) {
    rest_service()
      .get('/todos?select=id,todo')
      .expect('Content-Type', /json/)
      .expect(r => {
        r.body.length.should.equal(3)
        r.body[0].id.should.equal(1)
      })
      .expect(200, done)
  })

  it('by primary key', function (done) {
    rest_service()
      .get('/todos?select=id,todo&id=eq.1')
      .set('Accept', 'application/vnd.pgrst.object+json')
      .expect(r => {
        r.body.id.should.equal(1)
        r.body.todo.should.equal('item_1')
      })
      .expect(200, done)
  })
})
