db = require('../utils/db2')
router = require('express').Router()

router
.get('/category', (req, res, next) ->
  db((query) ->
    query('SELECT * FROM categories')
  )
  .then((rs) -> res.send(rs.rows.map((row) -> row.category)))
  .catch(next)
)
.get('/manufacturer', (req, res, next) ->
  db((query) ->
    query('SELECT * FROM manufacturers')
  )
  .then((rs) ->
    res.send(rs.rows.map((row) -> row.manufacturer))
  )
  .catch(next)
)
.get('/:id', (req, res, next) ->
  db((query) ->
    query('SELECT * FROM products WHERE id = $1', [req.params.id])
  )
  .then(({rows}) ->
    if rows.length == 0
      res.status(400).send(message: 'Item does not exist.')
    else
      res.send(rows[0])
  )
  .catch(next)
)
.get('/', (req, res, next) ->
  db((query) ->
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
  )
  .then((rs) -> res.send(rs.rows))
  .catch(next)
)
module.exports = router
