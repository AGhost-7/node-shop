should = require('should')
request = require('supertest')
dbmocker = require('./utils/dbmocker')
querystring = require('querystring')

app = undefined
agent = undefined

# I don't want a clean app for each bullet point, but starting a file of tests
# with a clean DB is going to save me some headaches.
before (done) ->
  process.env['testMode'] = true
  dbmocker( ->
    app = require('../../app')
    agent = request.agent(app)
    done()
  )


describe 'products lister', ->
  it 'should give all products in application', (done) ->
    agent
      .get('/product')
      .expect(200)
      .expect((res) ->
        # Should have an assortment of different categories/manufacturers
        checks = [
          res.body.some((prod) -> prod.category == 'Electric Drums')
          res.body.some((prod) -> prod.category == 'Ukuleles')
          res.body.some((prod) -> prod.manufacturer == 'Fender')
          res.body.some((prod) -> prod.manufacturer == 'Gretsch')
        ]
        !checks.every((ch) -> ch)
      )
      .end(done)

  it 'should filter by manufacturer', (done) ->
    agent
      .get('/product')
      .query(querystring.stringify(manufacturer: 'Yamaha'))
      .expect(200)
      .expect((res) -> !res.body.every((prod) -> prod.manufacturer == 'Yamaha'))
      .end(done)

  it 'should filter by category', (done) ->
    agent
      .get('/product')
      .query(querystring.stringify(category: 'Trumpets'))
      .expect(200)
      .expect((res) -> !res.body.every((prod) -> prod.category == 'Trumpets'))
      .end(done)
