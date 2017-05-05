var {graphql_simple, graphql_relay, jwt, resetdb} = require('../common.js');
var graphql = graphql_simple
const should = require("should");

describe('read', function() {

  after(function(done){ resetdb(); done(); });

  it('can get all items', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        query: `{ items { id name } }`
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.items.length.should.equal(4);
      })
      
  });

  it('can get items and subitems', function(done) {
    graphql()
      .set('Authorization', 'Bearer ' + jwt)
      .send({ 
        query: `
          {
            items{
              id
              name
              subitems{
                id
                name
              }
            }
          }

        `
      })
      .expect('Content-Type', /json/)
      .expect(200, done)
      .expect( r => {
        r.body.data.items.length.should.equal(4);
        r.body.data.items[0].subitems.length.should.equal(2);
        r.body.data.items[0].name.should.equal("item_1");
        r.body.data.items[0].subitems[1].name.should.equal("subitem_2");
      })
      
  });

});






