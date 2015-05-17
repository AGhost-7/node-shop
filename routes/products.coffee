db = require('../utils/db')
router = require('express').Router()



router
.get('/', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)
    # Written this way it will be easy to add more optional params.
    fields = [
      { name: 'manufacturer', val: req.query.manufacturer }
      { name: 'category', val: req.query.category }
    ]
    [sql, args] = fields.reduce(([sql, args], field) ->
      console.log(field.name,field.val)
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
.get('/categories', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)
    query('SELECT * FROM categories')
      .then((rs) -> res.send(rs.rows))
      .catch(next)
      .finally(done)
  )
)
.get('/manufacturers', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

    query('SELECT * FROM manufacturers')
      .then((rs) -> res.send(rs.rows))
      .catch(next)
      .finally(done)
  )
)

module.exports = router
