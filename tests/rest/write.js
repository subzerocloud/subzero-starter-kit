import { rest_service, resetdb } from '../common'
import should from 'should'

describe('write', function () {
  before(function (done) { resetdb(); done() })
  after(function (done) { resetdb(); done() })

  it('basic', function (done) {
    rest_service()
      .post('/todos')
      .withRole('webuser')
      .send({
      	todo: 'todo_post',
      	private: false
      })
      .expect(201, done)
  })
})
