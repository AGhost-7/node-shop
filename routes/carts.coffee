router = require('express').Router()
db = require('../utils/db2')
_ = require('lodash')
User = require('../utils/user')

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
  {params: {product, quantity}} = req

  if not product?
    res.status(400).send(message: 'Product id required.')
  else if not quantity? or quantity < 1
    res.status(400).send(message: 'You need to specify a quantity.')
  else
    db((query) ->
      User.ifLoggedIn(req, res, query, (userId) ->
        # to add the product to the cart, we must decrement product count,
        # therefore we must check if product is in stock.
        query('SELECT * FROM products WHERE id = $1', [product])
          .then(({rows}) ->
            if rows.length == 0
              res.status(400).send(message: 'Product does not exist.')
            else if rows[0].quantity - quantity < 0
              res.status(400).send(message: 'Not enough in stock.')
            else
              query('
                  WITH modified_prod AS (
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
  {params: {id}} = req
  if not id?
    res
      .status(400)
      .send(message: 'Entry to remove from cart must be specified.')
  else
    db((query) ->
      User.ifLoggedIn(req, res, query, (userId) ->
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
            ', [userId, id])
            .then(({rowCount}) ->
              if rowCount > 0
                query('
                    WITH subtotal AS (
                      SELECT sum(held_products.quantity * price) AS subtotal
                      FROM held_products
                      INNER JOIN products
                        ON products.id = held_products.product_id
                      WHERE user_id = $1
                    ),
                    tax AS (
                      SELECT round(subtotal * 0.13, 2) AS tax FROM subtotal
                    )
                    SELECT subtotal, tax, subtotal + tax AS total
                    FROM subtotal, tax
                    ', [userId])
                  .then(({rows: [row]}) ->
                    res.status(200).send(
                      message: 'Entry was removed.'
                      subtotal: row.subtotal || 0.0
                      tax: row.tax || 0.0
                      total: row.total || 0.0
                    )
                  )
              else
                res
                  .status(400)
                  .send(message: 'Entry was not found and could not be removed.')
            )
        ###
        query('
            WITH unheld_products AS (
              DELETE FROM held_products
              WHERE user_id = $1 AND id = $2
              RETURNING quantity, product_id
            ),
            ups AS (
              UPDATE products
              SET quantity = products.quantity + unheld_products.quantity
              FROM unheld_products
              WHERE products.id = unheld_products.product_id
            ),
            subtotal AS (
              SELECT sum(held_products.quantity * price) AS subtotal
              FROM held_products
              INNER JOIN products
                ON products.id = held_products.product_id
              WHERE user_id = $1
            ),
            tax AS (
              SELECT round(subtotal * 0.13, 2) AS tax FROM subtotal
            )
            SELECT subtotal, tax, subtotal + tax AS total
            FROM subtotal, tax, unheld_products
            ', [userId, id])
          .then(({rows: [row], rowCount}) ->
            if rowCount > 0
              res.status(200).send(
                message: 'Entry was removed.'
                subtotal: row.subtotal
                tax: row.tax
                total: row.total
              )
            else
              res
                .status(400)
                .send(message: 'Entry was not found and could not be removed.')
          )
        ###
      )
    )
    .catch(next)
)



module.exports = router
