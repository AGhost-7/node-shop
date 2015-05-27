Promise = require('bluebird')

User = {
  idFromReq: (req, query) ->
    query('SELECT * FROM tokens WHERE value = $1 AND ip = $2',
        [req.cookies.token, req.connection.remoteAddress])
      .then(({rows}) ->
        if rows.length == 0 then undefined else rows[0].user_id
      )

  ifLoggedIn: (req, res, query, whenLogged) ->
    if not req.cookies.token?
      Promise.resolve(res.status(401).send(message: 'You are not logged in.'))
    else
      query('SELECT * FROM tokens WHERE value = $1 AND ip = $2',
          [req.cookies.token, req.connection.remoteAddress])
        .then(({rows}) ->
          if rows.length == 1
            whenLogged(rows[0].user_id)
          else
            res.status(401).send(message: 'You are not logged in.')
        )

}

module.exports = User
