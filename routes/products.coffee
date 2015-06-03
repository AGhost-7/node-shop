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
#
.get('/', (req, res, next) ->
  db((query) ->

    # Written this way it will be easy to add more optional params.
    fields = [
      { name: 'manufacturer', val: req.query.manufacturer, op: '=' }
      { name: 'category', val: req.query.category, op: '=' }
      { name: 'price', val: req.query.minprice, op: '>=' }
      { name: 'price', val: req.query.maxprice, op: '<=' }
      {
        name: 'name'
        val: if req.query.name? then '%' + req.query.name + '%' else undefined
        op: 'ILIKE'
      }
    ]

    [sql, args] = fields.reduce(([sql, args], field) ->
      if field.val?
        [
          sql + " AND #{field.name} #{field.op} $#{args.length + 1}"
          args.concat(field.val)
        ]
      else
        [sql, args]
    , ['SELECT * FROM products WHERE quantity > 0',[]])

    if req.query.order?
      switch req.query.order
        when 'price-asc' then sql += ' ORDER BY price ASC'
        when 'price-des' then sql += ' ORDER BY price DESC'
        when 'name-des' then sql += ' ORDER BY name DESC'
        when 'name-asc' then sql += ' ORDER BY name ASC'

    if req.query.page?
      sql += " LIMIT 20 OFFSET ($#{args.length + 1} - 1) * 20"
      args.push(req.query.page)

    query(sql, args)
  )
  .then((rs) -> res.send(rs.rows))
  .catch(next)
)


module.exports = router
