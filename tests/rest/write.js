import { rest_service, resetdb } from '../common'
import should from 'should'

describe('write', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

  it('update a todo', function() {
    return rest_service()
      .put('/todos/1')
      .withRole('webuser')
      .send({
        // uncommenting this will yield a 'View columns that are not columns of their base relation are not updatable.'
        // id: null,
        // if we don't we got a 'You must specify all columns in the payload when using PUT'
        row_id: '1',
        todo: 'test updated',
        private: false,
        mine: false,
      })
      .expect(r => {
        r.body.should.equal('Object{}')
      })
      .expect(res => res.statusCode.should.equal(201))
      .expect('Location', /todos\?id=eq\./);
  });
})

