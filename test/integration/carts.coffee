should = require('should')
request = require('supertest')
dbmocker = require('./utils/dbmocker')
querystring = require('querystring')

app = undefined
agent = undefined
products = undefined
one = undefined
three = undefined

before (done) ->
  process.env['testMode'] = true
  dbmocker( ->
    app = require('../../app')
    agent = request.agent(app)
    agent
      .get('/product')
      .query(querystring.stringify(manufacturer: 'Godin'))
      .end((err, res) ->
        if err then throw err
        products = res.body
        one = products.reduce((accu, elem) ->
          if elem.quantity == 1 then elem else accu
        )
        three = products.reduce((accu, elem) ->
          if elem.quantity == 3 then elem else accu
        )
        # Just need to be logged in as a user
        agent
          .post('/user/login')
          .type('form')
          .send(name: 'foobaz', password: 'foobaz')
          .end(done)
      )
  )



describe 'Adding stuff to cart', ->

  it 'should allow me to add a valid item to my cart', (done) ->
    agent
      .post("/cart/#{one.id}/1")
      .expect(200)
      .end(done)

  it 'should decrement the count by one', (done) ->
    agent
      .get('/product/' + one.id)
      .expect(200)
      .expect((res) ->
        res.body.quantity.should.equal(0)
      )
      .end(done)

  it 'should prevent me from decrementing below 0', (done) ->
    agent
      .post("/cart/#{one.id}/1")
      .expect(400)
      .end(done)

  it 'should allow adding to cart three of the same item ', (done) ->
    agent
      .post("/cart/#{three.id}/3")
      .expect(200)
      .end(done)

  it 'should also decrement by three', (done) ->
    agent
      .get('/product/' + three.id)
      .expect(200)
      .expect((res) ->
        res.body.quantity.should.equal(0)
      )
      .end(done)

describe 'Viewing cart', ->

  it 'should display pending purchases', (done) ->
    agent
      .get('/cart')
      .expect(200)
      .expect((res) ->
        res.body.length.should.equal(2)
        res.body.should.containDeep([
          { product_id: one.id, quantity: 1 }
          { product_id: three.id, quantity: 3 }
        ])
      )
      .end(done)

describe.skip 'Cart removal', ->
  before (done) ->

  it 'should remove from my cart the entry', (done) ->
    agent
      .delete('/cart')

  it 'should increment the products', (done) ->

  it 'should re-increment products if account gets deleted', (done) ->
