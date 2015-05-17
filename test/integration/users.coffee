
should = require('should')
dbmocker = require('./utils/dbmocker')
request = require('supertest')

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

describe 'first time registration', ->

  it 'should slap my hand if I dont hand over a proper email', (done) ->
    agent
      .post('/user/register')
      .type('form')
      .send(name: 'foobar', password: 'foobar', email: 'foobar.com')
      .expect(400)
      .end(done)

  it 'should return ok when registering with a valid form', (done) ->
    agent
      .post('/user/register')
      .type('form')
      .send(name: 'foobar', password: 'foobar', email: 'foobar@gmail.com')
      .expect(200)
      .end(done)

  it 'should make me logged in', (done) ->
    agent
      .get('/user')
      .expect(200)
      .end(done)

describe 'login api', ->
  before (done) ->
    agent
      .post('/user/logout')
      .end(done)

  it 'shouldn\'t let me log in without proper creds', (done) ->
    agent
      .post('/user/login')
      .type('form')
      .send(name: 'foobar', password:'i dont know my password')
      .expect(400)
      .end(done)

  it 'should let log me in if I have the valid password', (done) ->
    agent
      .post('/user/login')
      .type('form')
      .send(name: 'foobar', password: 'foobar')
      .expect(200)
      .end(done)

  it 'should set the user token so that I can be identified', (done) ->
    agent
      .get('/user/')
      .expect(200)
      .end(done)
