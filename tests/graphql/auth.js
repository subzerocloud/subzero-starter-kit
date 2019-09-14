import { graphql_simple, resetdb } from '../common'
import should from 'should'
const graphql = graphql_simple

describe('auth', function() {
  
  before(function(done){ resetdb(); done(); });
  after(function(done){ resetdb(); done(); });
  
  it('can login', function(done) {
    graphql()
      .send({ 
        query: `mutation { login(email:"alice@email.com", password: "pass"){ id, email } }`
      })
      .expect(200, done)
      .expect('Content-Type', /json/)
      .expect(r => {
        //console.log(r.body)
        r.body.data.login.email.should.equal('alice@email.com');

      }, done)
      .expect('set-cookie', /SESSIONID/)
  });

  it('signup', function(done) {

    graphql()
      .send({ 
        query: `mutation { signup( name: "John Doe", email:"john@email.com", password: "pass"){ id, email } }`
      })
      .expect(200, done)
      .expect('Content-Type', /json/)
      .expect(r => {
        //console.log(r.body)
        r.body.data.signup.email.should.equal('john@email.com');

      })
  });
  
});
