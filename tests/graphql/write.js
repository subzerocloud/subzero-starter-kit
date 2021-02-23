const {graphql_simple, resetdb} = require('../common.js');
const graphql = graphql_simple

describe('write', function() {

  before(function(done){ resetdb(); done(); });
  after(function(done){ resetdb(); done(); });

  it('can insert one todo', function(done) {
    graphql()
      .withRole('webuser')
      .send({ 
        query: `
          mutation {
            insert{
              todo(input: {todo: "new name"}){
                id
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
        r.body.data.insert.todo.id.should.be.type('number');
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
                id
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
        r.body.data.insert.todos[0].id.should.be.type('number');
        r.body.data.insert.todos[1].todo.should.equal('item 2');
        r.body.data.insert.todos[1].id.should.be.type('number');
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
              todo(id: 1, input: {todo: "new name 1"}){
                id
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
        r.body.data.update.todo.id.should.be.type('number');
        r.body.data.update.todo.id.should.equal(1)
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
              todos(where: {id:{in:[2,3]}} input: {todo: "new name 2"}){
                id
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
        r.body.data.update.todos[0].id.should.be.type('number');
        r.body.data.update.todos[1].todo.should.equal('new name 2');
        r.body.data.update.todos[1].id.should.be.type('number');
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
              todo(id:1){
                id
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
        r.body.data.delete.todo.id.should.be.type('number');
        r.body.data.delete.todo.id.should.equal(1);
      })
      
  });

});

