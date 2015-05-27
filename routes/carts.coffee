router = require('express').Router()
db = require('../utils/db2')
_ = require('lodash')
User = require('../utils/user')

###
.get('/', (req, res, next) ->
  db((query) ->
    token = req.cookies.token
    if not token?
      res.status(401).send(message: 'You must be logged in.')
    else
      query('SELECT * FROM tokens WHERE value = $1 AND ip = $2',
          [token, req.connection.remoteAddress])
        .then(({rows}) ->
          if rows.length == 0
            res.status(401).send(message: 'You are not logged in.')
          else
            query('SELECT * FROM held_products WHERE user_id = $1',
                [rows[0].user_id])
              .then(({rows}) -> res.status(200).send(rows))
        )

  )
  .catch(next)
)
###

router
.get('/', (req, res, next) ->
  db((query) ->
    User.ifLoggedIn(req, res, query, (userId) ->
      # JFF
      query('
          WITH
            prod AS (
              SELECT held_products.id, held_products.quantity, price,
                  category, manufacturer, name, product_id
              FROM held_products
              INNER JOIN products
                ON products.id = held_products.product_id
              WHERE user_id = $1
            ),
            subtotal AS (
              SELECT sum(price * quantity) AS subtotal FROM prod
            ),
            tax AS (
              SELECT round(subtotal * 0.13, 2) AS tax FROM subtotal
            ),
            total AS (
              SELECT subtotal + tax AS total FROM subtotal, tax
            )
          SELECT * FROM prod, subtotal, tax, total
          ', [userId])
        .then(({rows}) ->
          if rows.length == 0
            items: []
            subtotal: 0.0
            total: 0.0
          else
            items: _.map(rows, (e) ->
              _.omit(e, ['subtotal', 'tax', 'total'])
            )
            subtotal: rows[0].subtotal
            tax: rows[0].tax
            total: rows[0].total
        )
        .then((data) ->
          res.status(200).send(data)
        )
    )

  )
)
.post('/:product/:quantity', (req, res, next) ->
  {params: {product,quantity}, cookies: {token}} = req

  if not product?
    res.status(400).send(message: 'Product id required.')
  else if not quantity? or quantity < 1
    res.status(400).send(message: 'You need to specify a quantity.')
  else if not token
    res.status(401).send(message: 'You must me logged in to access your cart.')
  else
    db((query) ->
      # to add the product to the cart, we must decrement product count,
      # therefore we must check if product is in stock.
      query('SELECT * FROM products WHERE id = $1', [product])
        .then(({rows}) ->
          if rows.length == 0
            res.status(400).send(message: 'Product does not exist.')
          else if rows[0].quantity - quantity < 0
            res.status(400).send(message: 'Not enough in stock.')
          else
            query('SELECT * FROM tokens WHERE value = $1 AND ip = $2',
                [token, req.connection.remoteAddress])
              .then(({rows}) ->
                if rows.length == 0
                  res.status(401).send(message: 'You are not logged in.')
                else
                  userId = rows[0].user_id
                  query('
                      WITH modified_prod AS
                      (
                      	UPDATE products
                      	SET quantity = quantity - $3
                      	WHERE products.id = $1
                      	RETURNING id
                      )
                      INSERT INTO held_products(product_id, user_id, quantity)
                      SELECT modified_prod.id, $2, $3
                      FROM modified_prod
                      ', [product, userId, quantity])
                    .then((rs) ->
                      res.status(200).send(message: 'Product added to cart.')
                    )
              )
        )

    )
    .catch(next)
)

.delete('/:id', (req, res, next) ->
  {params: {id}, cookies: {token}} = req
  if not id?
    res
      .status(400)
      .send(message: 'Entry to remove from cart must be specified.')
  else if not token?
    res
      .status(401)
      .send(message: 'You are not logged in.')
  else
    db((query) ->
      query('SELECT * FROM tokens WHERE value = $1 AND ip = $2',
          [token, req.connection.remoteAddress])
        .then(({rows}) ->
          if rows.length == 0
            res.status(401).send(message: 'You are not logged in.')
          else
            query('
                WITH unheld_products AS (
                	DELETE FROM held_products
                	WHERE user_id = $1 AND id = $2
                  RETURNING quantity, product_id
                )
                UPDATE products
                SET quantity = products.quantity + unheld_products.quantity
                FROM unheld_products
                WHERE products.id = unheld_products.product_id
                ', [rows[0].user_id, id])
              .then(({rowCount}) ->
                if rowCount > 0
                  res.status(200).send(message: 'Entry was removed.')
                else
                  res
                    .status(400)
                    .send(message: 'Entry was not found and could not be removed.')
              )
        )
    )
    .catch(next)
)



module.exports = router
