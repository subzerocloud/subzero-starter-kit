var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple

describe('write', function() {

  before(function(done){ resetdb(); done(); });
  after(function(done){ resetdb(); done(); });

  it('can insert one todo', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        //query: `{ todos { id name } }`
        query: `
          mutation {
            insert{
              todo(input: {todo: "new name"}){
                row_id
                todo
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        //console.log(r.body.data)
        //r.body.data.todos.length.should.equal(10);
        r.body.data.insert.todo.todo.should.equal('new name');
        r.body.data.insert.todo.row_id.should.be.type('number');
      })
      
  });

  it('can insert multiple', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        //query: `{ todos { id name } }`
        query: `
          mutation {
            insert{
              todos(input: [{todo: "item 1"}, {todo: "item 2"}]){
                row_id
                todo
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.insert.todos.length.should.equal(2);
        r.body.data.insert.todos[0].todo.should.equal('item 1');
        r.body.data.insert.todos[0].row_id.should.be.type('number');
        r.body.data.insert.todos[1].todo.should.equal('item 2');
        r.body.data.insert.todos[1].row_id.should.be.type('number');
      })
      
  });

  // TODO!!!!!!!!!  bad fail 500 if the id is not found
  it('can update one todo', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        //query: `{ todos { id name } }`
        query: `
          mutation {
            update{
              todo(row_id: 1, input: {todo: "new name 1"}){
                row_id
                todo
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        //r.body.data.items.length.should.equal(10);
        r.body.data.update.todo.todo.should.equal('new name 1');
        r.body.data.update.todo.row_id.should.be.type('number');
        r.body.data.update.todo.row_id.should.equal(1)
      })
      
  });

  it('can update multiple todos', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        //query: `{ todos { id name } }`
        query: `
          mutation {
            update{
              todos(where: {row_id:{in:[2,3]}} input: {todo: "new name 2"}){
                row_id
                todo
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.update.todos.length.should.equal(2);
        r.body.data.update.todos[0].todo.should.equal('new name 2');
        r.body.data.update.todos[0].row_id.should.be.type('number');
        r.body.data.update.todos[1].todo.should.equal('new name 2');
        r.body.data.update.todos[1].row_id.should.be.type('number');
      })
      
  });

  it('can delete one todo', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        //query: `{ todos { id name } }`
        query: `
          mutation {
            delete{
              todo(row_id:1){
                row_id
                todo
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.delete.todo.todo.should.equal('new name 1');
        r.body.data.delete.todo.row_id.should.be.type('number');
        r.body.data.delete.todo.row_id.should.equal(1);
      })
      
  });

});

