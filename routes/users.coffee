express = require('express')
router = express.Router()
#db = require('../utils/db')
db = require('../utils/db2')
ncrypt = require('../utils/ncrypt')

User = require('../utils/user')

router
.get('/', (req, res, next) ->
  db((query) ->
    query('
        SELECT * FROM users
        INNER JOIN tokens ON users.id = tokens.user_id
        WHERE tokens.value = $1 AND tokens.ip = $2
        ', [req.cookies.token, req.connection.remoteAddress])
  )
  .then(({rows}) ->
    if rows.length == 0
      res.status(401).send(message: "You are not logged in.")
    else
      user = rows[0]
      res.send(message: "You are logged in.", name: user.name)
  )
  .catch(next)
)
.delete('/', (req, res, next) ->
  db((query) ->
    User.ifLoggedIn(req, res, query, (userId) ->
      query('DELETE FROM tokens WHERE user_id = $1 AND ip = $2',
          [userId, req.connection.remoteAddress])
        .then( ->
          # In a realistic context, I don't think you'd ever want to delete
          # purchase data.
          query('UPDATE users SET deleted = true WHERE id = $1', [userId])
        )
        .then( ->
          query('
              WITH unheld_products AS (
                DELETE FROM held_products
                WHERE user_id = $1
                RETURNING quantity, product_id
              )
              UPDATE products
              SET quantity = products.quantity + unheld_products.quantity
              FROM unheld_products
              WHERE products.id = unheld_products.product_id
              ', [userId])
        )
        .then((rs) ->
          res
            .clearCookie('token')
            .send(message: "Your account was deleted successfully.")
        )
    )
  )
  .catch(next)
)
.post('/register', (req, res, next) ->

  if not req.body.name? or req.body.name.length < 5
    res
      .status(400)
      .send(message: "Name must be at least 5 characters long.")
  else if not req.body.password? or req.body.password.length < 5
    res
      .status(400)
      .send(message: "Password must be at least 5 characters long.")
  else if not req.body.email? or not req.body.email.match(/.+@.+[.].+/g)
    res
      .status(400)
      .send(message: "Email is invalid")
  else
    db((query) ->
      query('SELECT * FROM users WHERE name = $1 AND deleted = false',
          [req.body.name])
        .then((rs) ->
          if rs.rows.length > 0
            res
              .status(400)
              .send(message: "There already exists a user of that name")
          else
            ncrypt
              .randHex(64)
              .then((salt) -> ncrypt.hashPw(req.body.password, salt))
              .then((hashed) ->
                # password hash also contains the salt
                query('
                    INSERT INTO users("name", "password", email)
                    VALUES($1,$2,$3) RETURNING id
                    ', [req.body.name, hashed, req.body.email])
              )
              .then(({rows: [row]}) ->
                ncrypt.randHex(64).then((tk) ->
                  [row.id, tk]
                )
              )
              .spread((id, tk) ->
                query('
                    INSERT INTO tokens("value", user_id, ip)
                    VALUES ($1, $2, $3)
                    ', [tk, id, req.connection.remoteAddress])
                  .then( ->
                    res.cookie('token', tk).send(message: 'Success')
                  )
              )

        )
    )
    .catch(next)
)
.post('/login', (req, res, next) ->
  db((query) ->
    query('SELECT * FROM users WHERE "name" = $1', [req.body.name])
      .then(({rows}) ->
        if rows.length == 0
          res.status(400).send(message: "Username is invalid.")
        else
          ncrypt
            .compare(rows[0].password, req.body.password)
            .then((equal) ->
              if equal
                ncrypt
                  .randHex(64)
                  .then((tkn) ->
                    query('
                        INSERT INTO tokens("value", user_id, ip)
                        VALUES ($1, $2, $3)
                        RETURNING "value"
                        ', [tkn, rows[0].id, req.connection.remoteAddress])
                  )
                  .then(({rows: [row]}) ->
                    res
                      .cookie('token', row.value)
                      .send(message: "Login successful")
                  )
              else
                res.status(400).send(message: "Failed authentication.")
            )
      )
  )
  .catch(next)
)
.post('/logout', (req, res, next) ->
    if not req.cookies.token?
      res.status(400).send(message: "You are not logged in.")
    else
      db((query) ->
        User.ifLoggedIn(req, res, query, (userId) ->
          query('DELETE FROM tokens WHERE "value" = $1', [req.cookies.token])
          .then((rs) ->
            res.clearCookie('token')
            if rs.rowCount > 0
              res.send(message: "Logged out.")
            else
              res.status(401).send(message: "Your session is not valid.")
          )
        )
      )
      .catch(next)
)

module.exports = router
