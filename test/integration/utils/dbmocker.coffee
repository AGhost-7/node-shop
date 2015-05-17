
###
  This module builds a fresh test database. Using environment variables, you
  can make the application connect to the test database instead of the one
  its normally supposed to use.
###

pg = require('pg')
fs = require('fs')
path = require('path')

# Files that will be executed, in order.
execSqlFiles = [
  'tables.sql'
]


execSqlScript = (dir, client, done) ->
  client.connect((err) ->
    if err then throw err
    sqls = fs
      .readFileSync(dir)
      .toString()
      # Normally this would've been a simple lookbefore... Going to run into
      # some issues using stored functions since this will split the function
      # into multiple parts, probably resulting in an error. To prevent stored
      # function from getting split, you can use double semi-colons. This is
      # still going to be valid SQL without parsing it.
      .replace(";;", "-!-")
      .split(";")
      .map (sql) -> sql.replace("-!-", ";")

    execSqlStatements = (i) ->
      client.query(sqls[i], (err, rs) ->
        if err
          console.log('---ERROR AT---')
          console.log(sqls[i])
          throw err
        if i < sqls.length - 1 then execSqlStatements(i + 1)
        else done()
      )

    execSqlStatements(0)
  )

buildDB = (i, client, done) ->
  filePath = path.join(__dirname, '../../../sql', execSqlFiles[i])
  doneScript = ->
    if i < execSqlFiles.length - 1
      buildDB(i + 1, client, done)
    else
      done()
  try
    execSqlScript(filePath, client, doneScript)
  catch err
    done()
    throw err

module.exports = (done) ->
  # Postgres comes with this database already created, I guess its for doing this
  # sort of stuff.
  client = new pg.Client('postgres://postgres:postgres@localhost:5432/template1')

  client.connect((err) ->
    if err then throw err
    client.query('DROP DATABASE IF EXISTS testing_db', (err,rs) ->
      if err? then throw err

      client.query('CREATE DATABASE testing_db', (err, rs) ->
        if err? then throw err
        client.end()
        client = new pg.Client('postgres://postgres:postgres@localhost:5432/testing_db')
        buildDB(0, client, ->
          client.end()
          done()
        )
      )
    )
  )
