var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple

describe('auth', function() {
  
  before(function(done){ resetdb(); done(); });
  
  it('can login', function(done) {
    graphql()
      .send({ 
        query: `{ login(email:"alice@email.com", password: "pass"){ me } }`
      })
      .expect(200, done)
      .expect('Content-Type', /json/)
      .expect('set-cookie', /SESSIONID/)
      .expect(r => {
        r.body.data.login.me.email.should.equal('alice@email.com');

      })
  });

  it('signup', function(done) {

    graphql()
      .send({ 
        query: `mutation { signup( name: "John Doe", email:"john@email.com", password: "pass"){ me } }`
      })
      .expect(200, done)
      .expect('Content-Type', /json/)
      .expect(r => {
        r.body.data.signup.me.email.should.equal('john@email.com');

      })
  });
  
});
