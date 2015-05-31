
express = require('express')
http = require('http')
path = require('path')
fs = require('fs')
bodyParser = require('body-parser')

app = express()

if process.env.MODE != 'test'
  app.use(require('morgan')('dev'))

app
  .use(bodyParser.json())
  .use(bodyParser.urlencoded({extended: true}))
  .use(require('cookie-parser')())
  .use('/html', express.static(path.join(__dirname, 'html')))

fileLoader = (url, dir, type) ->
  app.get(url, (req, res) ->
    stream = fs.createReadStream(path.join(__dirname, dir))
    res.header('Content-Type', type)
    stream.pipe(res)
  )

mainFile = if process.env.MODE == 'prod' then 'main.min.js' else 'main.js'
fileLoader('/main', 'main.js', 'application/javascript')
fileLoader('/main.js.map', 'main.js.map', 'application/javascript')
fileLoader('/', 'html/index.html', 'text/html')

app
  .use('/user', require('./routes/users'))
  .use('/product', require('./routes/products'))
  .use('/cart', require('./routes/carts'))
  .use('/purchase', require('./routes/purchases'))

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
