# password functions
crypto = require('crypto')
#Q = require('q')
Promise = require('bluebird')

ncrypt =
  randHex: (ln) ->
    new Promise((resolve, reject) ->
      crypto.randomBytes(ln, (err, rand) ->
        if(err) then reject(err)
        else resolve(rand.toString('hex'))
      )
    )

  hashPw: (password, salt) ->
    new Promise((resolve, reject) ->
      crypto.pbkdf2(password, salt, 4096, 512, 'sha256', (err, hashed) ->
        if err then reject(err)
        else
          resolve(hashed.toString('hex') + ":" + salt)
      )
    )

  compare: (stored, input) ->
    [pw, salt] = stored.split(":")

    ncrypt
      .hashPw(input, salt)
      .then((hashedInput) ->
        hashedInput == stored
      )

module.exports = ncrypt
