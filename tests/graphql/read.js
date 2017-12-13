var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple
const should = require("should");

describe('read', function() {

  before(function(done){ resetdb(); done(); });

  it('can get all todos', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        query: `{ todos { id todo } }`
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        // console.log(r.body)
        r.body.data.todos.length.should.equal(4);
      })
      
  });

  it.skip('can get todos and subtodos', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        query: `
          {
            todos{
              id
              todo
              subtodos{
                id
                subtodo
              }
            }
          }

        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.todos.length.should.equal(4);
        r.body.data.todos[0].subtodos.length.should.equal(2);
        r.body.data.todos[0].name.should.equal("item_1");
        r.body.data.todos[0].subtodos[1].name.should.equal("subitem_2");
      })
      
  });

});






