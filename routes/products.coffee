db = require('../utils/db')
router = require('express').Router()



router
.get('/category', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)
    query('SELECT * FROM categories')
      .then((rs) -> res.send(rs.rows.map((row) -> row.category)))
      .catch(next)
      .finally(done)
  )
)
.get('/manufacturer', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

    query('SELECT * FROM manufacturers')
      .then((rs) ->
        res.send(rs.rows.map((row) -> row.manufacturer))
      )
      .catch(next)
      .finally(done)
  )
)
.get('/:id', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

    query('SELECT * FROM products WHERE id = $1', [req.params.id])
      .then(({rows}) ->
        if rows.length == 0
          res.status(400).send(message: 'Item does not exist.')
        else
          res.send(rows[0])
      )
      .catch(next)
      .finally(done)
  )
)
.get('/', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)
    # Written this way it will be easy to add more optional params.
    fields = [
      { name: 'manufacturer', val: req.query.manufacturer }
      { name: 'category', val: req.query.category }
    ]
    [sql, args] = fields.reduce(([sql, args], field) ->
      if field.val?
        if args.length == 0
          sql += " WHERE #{field.name} = $#{args.length + 1}"
        else
          sql += " AND #{field.name} = $#{args.length + 1}"
        [sql, args.concat(field.val)]
      else
        [sql, args]
    , ['SELECT * FROM products',[]])

    query(sql, args)
      .then((rs) -> res.send(rs.rows))
      .catch(next)
      .finally(done)
  )
)
module.exports = router
