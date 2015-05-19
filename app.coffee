
express = require('express')
http = require('http')
path = require('path')
fs = require('fs')
bodyParser = require('body-parser')

app = express()

if not process.env.testMode?
  app.use(require('morgan')('dev'))

app
  .use(bodyParser.json())
  .use(bodyParser.urlencoded({extended: true}))
  .use(require('cookie-parser')())
  .use(express.static(path.join(__dirname, 'public')))

# Routes
app.get('/', (req, res) ->
  stream = fs.createReadStream(path.join(__dirname, 'index.html'))
  res.header('Content-Type', 'text/html')
  stream.pipe(res)
)

app
  .use('/user', require('./routes/users'))
  .use('/product', require('./routes/products'))
  .use('/cart', require('./routes/carts'))

# If nothing found... something went wrong
app.use((req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)
)

app.use((err, req, res, next) ->
  res.status(err.status || 500)
  res.send(err)
)

module.exports = app
