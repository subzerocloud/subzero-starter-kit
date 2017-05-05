var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple

describe('write', function() {

  after(function(done){ resetdb(); done(); });


  it('can insert one item', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        //query: `{ items { id name } }`
        query: `
          mutation {
            insert{
              item(input: {name: "new name"}){
                row_id
                name
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        //r.body.data.items.length.should.equal(10);
        r.body.data.insert.item.name.should.equal('new name');
        r.body.data.insert.item.row_id.should.be.type('number');
      })
      
  });

  it('can insert multiple', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        //query: `{ items { id name } }`
        query: `
          mutation {
            insert{
              items(input: [{name: "item 1"}, {name: "item 2"}]){
                row_id
                name
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.insert.items.length.should.equal(2);
        r.body.data.insert.items[0].name.should.equal('item 1');
        r.body.data.insert.items[0].row_id.should.be.type('number');
        r.body.data.insert.items[1].name.should.equal('item 2');
        r.body.data.insert.items[1].row_id.should.be.type('number');
      })
      
  });

  // TODO!!!!!!!!!  bad fail 500 if the id is not found
  it('can update one item', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        //query: `{ items { id name } }`
        query: `
          mutation {
            update{
              item(row_id: 1, input: {name: "new name 1"}){
                row_id
                name
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        //r.body.data.items.length.should.equal(10);
        r.body.data.update.item.name.should.equal('new name 1');
        r.body.data.update.item.row_id.should.be.type('number');
        r.body.data.update.item.row_id.should.equal(1)
      })
      
  });

  it('can update multiple item', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        //query: `{ items { id name } }`
        query: `
          mutation {
            update{
              items(where: {row_id:{in:[2,3]}} input: {name: "new name 2"}){
                row_id
                name
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.update.items.length.should.equal(2);
        r.body.data.update.items[0].name.should.equal('new name 2');
        r.body.data.update.items[0].row_id.should.be.type('number');
        r.body.data.update.items[1].name.should.equal('new name 2');
        r.body.data.update.items[1].row_id.should.be.type('number');
      })
      
  });

  it.skip('can delete one item', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        //query: `{ items { id name } }`
        query: `
          mutation {
            delete{
              item(row_id:1){
                row_id
                name
              }
            }
          }
        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        // TODO!!!!!!!!!  need to upgrade postgrest to get back and object
        console.log(r.body)
        r.body.data.delete.item.name.should.equal('item_3');
        r.body.data.delete.item.row_id.should.be.type('number');
        r.body.data.delete.item.row_id.should.equal(3);
      })
      
  });

});

