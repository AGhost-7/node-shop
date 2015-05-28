should = require('should')
request = require('supertest')
dbmocker = require('./utils/dbmocker')
pg = require('pg')


describe 'purchases', ->

  before (done) ->
    listToCart = (products, done) =>
      @agent
        .post('/cart/' + products[0].id + '/' + products[0].quantity)
        .end((err, res) ->
          if err then throw err
          if products.length > 1 then listToCart(products.slice(1), done)
          else done()
        )

    addCartItems = (done) =>
      @agent
        .get('/product')
        .end((err, res) =>
          if err then throw err
          @buyList = res.body.filter((e) -> e.quantity > 0).slice(0, 2)
          listToCart(@buyList, done)
        )

    process.env['testMode'] = true
    dbmocker( =>
      app = require('../../app')
      #server = http.createServer(app)
      @server = app.listen(0)
      @agent = request.agent(app)
      @agent
        .post('/user/login')
        .type('form')
        .send(name: 'foobaz', password: 'foobaz')
        .end((err, res) ->
          addCartItems(done)
        )
    )

  describe 'purchasing', ->

    it 'should return an ok...', (done) ->
      @agent
        .post('/purchase')
        .type('form')
        .send(method: 'Paypal')
        .expect(200)
        .end(done)

    it 'should empty the cart', (done) ->
      @agent
        .get('/cart')
        .expect(200)
        .expect((res) ->
          res.body.items.should.be.empty
        )
        .end(done)

  describe 'receipts', ->

    it 'should give me a list with my purchase in it', (done) ->
      @agent
        .get('/purchase')
        .expect(200)
        .expect((res) =>
          res.body.should.containDeep([
            {
              items: [
                { product_id: @buyList[0].id }
                { product_id: @buyList[1].id }
              ]
            }
          ])
        )
        .end(done)


  after (done) ->
    pg.end()
    @server.close(done)
