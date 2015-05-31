should = require('should')
request = require('supertest')
dbmocker = require('./utils/dbmocker')
querystring = require('querystring')
pg = require('pg')

describe 'Products', ->

  # I don't want a clean app for each bullet point, but starting a file of tests
  # with a clean DB is going to save me some headaches.
  before (done) ->
    process.env.MODE = 'test'
    dbmocker( =>
      app = require('../../app')
      @server = app.listen(0)
      @agent = request.agent(app)
      done()
    )

  describe 'single product request', (done) ->
    it 'should give me a single result', (done) ->
      @agent
        .get('/product/1')
        .expect(200)
        .expect((res) ->
          res.body.should.have.properties(['manufacturer', 'id'])
        )
        .end(done)

    it 'it should give an error if the entry doesnt exist', (done) ->
      @agent
        .get('/product/9999999')
        .expect(400)
        .end(done)

  describe 'products lister', ->
    it 'should give all products in application', (done) ->
      @agent
        .get('/product')
        .expect(200)
        .expect((res) ->
          res.body.should.containDeep([
            { category: 'Electric Drums' }
            { category: 'Ukuleles' }
            { manufacturer: 'Fender' }
            { manufacturer: 'Gretsch' }
          ])
        )
        .end(done)

    it 'should filter by manufacturer', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(manufacturer: 'Yamaha'))
        .expect(200)
        .expect((res) ->
          res.body.forEach((prod) -> prod.manufacturer.should.equal('Yamaha'))
        )
        .end(done)

    it 'should filter by category', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(category: 'Trumpets'))
        .expect(200)
        .expect((res) -> res.body.forEach((prod) -> prod.category.should.equal('Trumpets')))
        .end(done)

    it 'should filter by both category and manufacturer', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(category: 'Ukuleles', manufacturer: 'Mahalo'))
        .expect(200)
        .expect((res) ->
          res.body.forEach((prod) ->
              prod.category.should.equal('Ukuleles')
              prod.manufacturer.should.equal('Mahalo')
          )
        )
        .end(done)

    it 'should have pagination', (done) ->
      @agent
        .get('/product')
        .end((err, res) =>
          if err then throw err

          items = res.body
          @agent
            .get('/product')
            .query(querystring.stringify(page: 2))
            .expect(200)
            .expect((res) ->
              res.body[0].id.should.be.equal(items[20].id)
            )
            .end(done)
        )

    it 'should have the abilitiy to order things...', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(order: 'price-asc'))
        .expect(200)
        .expect((res) ->
          res.body.reduce((lastPrice, item) ->
            item.price.should.be.greaterThan(lastPrice - 1)
            item.price
          , 0)
        )
        .end(done)

    it 'hath filter prices', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(minprice: '50'))
        .expect(200)
        .expect((res) ->
          res.body.forEach((item) ->
            item.price.should.be.greaterThan(49)
          )
        )
        .end(done)

    it 'shalt filter by name', (done) ->
      @agent
        .get('/product')
        .query(querystring.stringify(name: 'Roland'))
        .expect(200)
        .expect((res) ->
          res.body.forEach((item) ->
            item.name.indexOf('Roland').should.not.be.equal(-1)
          )
        )
        .end(done)

  describe 'fields lister', ->
    it 'should give a list of all of the manufacturers', (done) ->
      @agent
        .get('/product/manufacturer')
        .expect(200)
        .expect((res) ->
          res.body.should.containDeep(['Fender', 'Yamaha', 'Roland', 'C.F. Martin'])
        )
        .end(done)

    it 'should give a list of all the categories', (done) ->
      @agent
        .get('/product/category')
        .expect(200)
        .expect((res) ->
          res.body.should.containDeep(['Ukuleles', 'Keyboards'])
        )
        .end(done)


  after (done) ->
    pg.end()
    @server.close(done)
