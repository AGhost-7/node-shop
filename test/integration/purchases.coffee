should = require('should')
request = require('supertest')
dbmocker = require('./utils/dbmocker')



describe.skip 'purchases', ->

  before (done) ->
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
          done()
        )
    )

  beforeEach (done) ->
    listToCart = (products, done) ->
      @agent
        .post('/cart/' + products[0].id + '/' + products[0].quantity)
        .end((err, res) ->
          if err then throw err
          if products.length > 1 then listToCart(products)
          else done()
        )
    @agent
      .get('/product')
      .end((err, res) ->
        if err then throw err
        buyList = err.body.filter((e) -> e.quantity > 0).slice(0, 2)
        listToCart(buyList, done)
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
          res.body.should.be.empty()
        )
        .end(done)




  describe 'receipts', ->
    before (done) ->
      @agent
      done()
