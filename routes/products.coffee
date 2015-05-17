db = require('../utils/db')
router = require('express').Router()

router
.get('/', (req, res, next) ->
  db((err, query, done) ->
    if err
      next(err)
    else
      query('SELECT * FROM products')
        .then((rs) -> res.send(rs.rows))
        .fail((err) -> next(err))
        .fin( -> done())
  )
)


module.exports = router
