var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple

describe('auth', function() {
  
  after(function(done){ resetdb(); done(); });
  
  it('can login', function(done) {
    graphql()
      .send({ 
        query: `{ login(email:"alice@email.com", password: "pass"){ email } }`
      })
      .expect(200, done)
      .expect('Content-Type', /json/)
      .expect('set-cookie', /SESSIONID/)
      .expect(r => {
        r.body.data.login.email.should.equal('alice@email.com');

      })
  });
  
});
