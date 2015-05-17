express = require('express')
router = express.Router()
db = require('../utils/db')
ncrypt = require('../utils/ncrypt')


router
.get('/', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

    query('SELECT * FROM users
        INNER JOIN tokens ON users.id = tokens.user_id
        WHERE tokens.value = $1 AND tokens.ip = $2',
        [req.cookies.token, req.connection.remoteAddress])
      .then(({rows}) ->
        if rows.length == 0
          res.status(400).send(message: "You are not logged in.")
        else
          user = rows[0]
          res.send(message: "You are logged in.", name: user.name)
      )
      .catch(next)
      .finally(done)
  )
)
.delete('/', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

    query('SELECT * FROM tokens WHERE "value" = $1 AND ip = $2',
        [req.cookies.token, req.connection.remoteAddress])
      .then(({ rows }) ->
        if rows.length == 0
          res.status(400).send(message: "You are not logged in.")
        else
          userId = rows[0].user_id
          query('DELETE FROM tokens WHERE user_id = $1', [userId])
            .then( ->
              query('DELETE FROM users WHERE id = $1', [userId])
            )
            .then( ->
              res
                .clearCookies('token')
                .send(message: "Your account was deleted successfully.")
            )
      )
      .catch(next)
      .finally(done)
  )
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
    db((err, query, done) ->
      if err then return next(err)

      query('SELECT * FROM users WHERE name = $1', [req.body.name])
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
                query('INSERT INTO users("name", "password", email)
                    VALUES($1,$2,$3) RETURNING id',
                    [req.body.name, hashed, req.body.email])
              )
              .then(({rows: [row]}) ->
                ncrypt.randHex(64).then((tk) ->
                  [row.id, tk]
                )
              )
              .spread((id, tk) ->
                query('INSERT INTO tokens("value", user_id, ip)
                    VALUES ($1, $2, $3)',
                    [tk, id, req.connection.remoteAddress])
                  .then( ->
                    res.cookie('token', tk).send(message: 'Success')
                  )
              )

        )
        .catch(next)
        .finally(done)
    )
)
.post('/login', (req, res, next) ->
  db((err, query, done) ->
    if err then return next(err)

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
                    query('INSERT INTO tokens("value", user_id, ip)
                        VALUES ($1, $2, $3)
                        RETURNING "value"',
                        [tkn, rows[0].id, req.connection.remoteAddress])
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
      .catch(next)
      .finally(done)
  )
)
.post('/logout', (req, res, next) ->
    if not req.cookies.token?
      res.status(400).send(message: "You are not logged in.")
    else
      db((err, query, done) ->
        if err then return next(err)

        query('DELETE FROM tokens WHERE "value" = $1', [req.cookies.token])
          .then((rs) ->
            res.clearCookie('token')
            
            if rs.rowCount > 0
              res.send(message: "Logged out.")
            else
              res.send(message: "Your session is not valid.")


          )
          .catch(next)
          .finally(done)
      )
)

module.exports = router
