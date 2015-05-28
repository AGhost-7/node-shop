db = require('../utils/db2')
router = require('express').Router()
User = require('../utils/user.coffee')
_ = require('lodash')

# View receipts with subtotal and total
router
.get('/', (req, res, next) ->
  db((query) ->
    User.ifLoggedIn(req, res, query, (userId) ->
      query('
        SELECT * FROM purchases
        INNER JOIN receipts
          ON receipt_id = receipts.id
        INNER JOIN products
          ON product_id = products.id
        WHERE user_id = $1
      ', [userId])
      .then(({rows}) ->
        res.send(
          _.chain(rows)
            .groupBy((row) -> row.receipt_id)
            .values()
            .map((rw) ->
              items: _.map(rw, (r) ->
                _.omit(r, ['id', 'subtotal', 'tax', 'user_id', 'stamp', 'method', 'receipt_id'])
              )
              subtotal: rw[0].subtotal
              tax: rw[0].tax
              total: rw[0].total
              stamp: rw[0].stamp
              id: rw[0].receipt_id
            )
            .value()
        )
      )
    )

  )
  .catch(next)
)
.get('/:id', (req, res, next) ->
  db((query) ->
    User.ifLoggedIn(req, res, query, (userId) ->
      query('
          SELECT * FROM purchases
          INNER JOIN receipts
            ON receipt_id = receipts.id
          INNER JOIN products
            ON product_id = products.id
          WHERE user_id = $1
            AND receipts.id = $2
          ', [userId, req.params.id])
    )
    .then(({ rows }) ->
      if rows.length == 0
        res.status(404).send(message: 'Entry was not found.')
      else
        res.send(
          products: _.map(rows, (rw) ->
            _.omit(rw, [
              'id', 'subtotal', 'tax', 'user_id', 'stamp'
            ])
          )
          tax: row[0].tax
          total: row[0].total
          subtotal: row[0].subtotal
          stamp: row[0].stamp
        )
    )
  )
  .catch(next)
)
# For now, that's all this is going to do.
.post('/', (req, res, next) ->
  db((query) ->
    User.ifLoggedIn(req, res, query, (userId) ->
      query('
        WITH
        	removed AS (
        		DELETE FROM held_products
        		USING products
        		WHERE products.id = product_id
        			AND user_id = $1
        		RETURNING held_products.quantity, product_id, price
        	),
        	subtotal AS (
        		SELECT sum(price * quantity) AS subtotal FROM removed
        	),
        	tax AS (
        		SELECT round(subtotal * 0.13, 2) AS tax FROM subtotal
        	),
        	total AS (
        		SELECT subtotal + tax AS total FROM subtotal, tax
        	),
        	receipt AS (
        		INSERT INTO receipts(subtotal, tax, total, user_id, method)
        		SELECT subtotal, tax, total, $1, $2
        		FROM subtotal, tax, total
        		RETURNING id
        	),
        	inserts AS (
        		INSERT INTO purchases(receipt_id, product_id, quantity)
        		SELECT receipt.id, product_id, quantity FROM removed, receipt
        	)
        SELECT * FROM receipt, subtotal, tax, total
      ', [userId, req.body.method])
        .then(({ rows }) ->
          res.status(200).send(rows[0])
        )
    )
  )
  .catch(next)
)

module.exports = router
