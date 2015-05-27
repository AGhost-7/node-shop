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
    )
    .then(({rows}) ->
      res.send(
        _.chain(rows)
          .groupBy((row) -> row.receipt_id)
          .values()
          .map((rw) ->
            items: _.omit(rw, [
              'id', 'subtotal', 'tax', 'user_id', 'stamp'
            ])
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
    .then(({rows}) ->
      if rows.length == 0
        res.status(404).send(message: 'Entry was not found.')
      else
        res.send(
          products: rows.map((rw) ->

          )
          tax: row[0].tax
          total: row[0].total
          subtotal: row[0].subtotal
          stamp: row[0].stamp
        )
    )
  )
)




# accept to purchase and proceed to pay using w/e...

module.exports = router
