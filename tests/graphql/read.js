import { graphql_simple, resetdb } from '../common'
import should from 'should'
const graphql = graphql_simple

describe('read', function() {

  before(function(done){ resetdb(); done(); });
  after(function(done){ resetdb(); done(); });

  it('can get all todos', function(done) {
    graphql()
      .withRole('webuser')
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
      .withRole('webuser')
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






