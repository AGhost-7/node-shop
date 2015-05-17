ncrypt = require('../../utils/ncrypt')
should = require('should')
Promise = require('bluebird')


describe 'Basic token generation', ->
  it 'should generate a random string of twice the number of bytes', ->
    ncrypt
      .randHex(64)
      .then((rand) ->
        rand.should.have.lengthOf(128)
      )
      .catch(should.not.exist)

  it 'should always be different', ->
    ncrypt
      .randHex(64)
      .then((rand) ->
        ncrypt
          .randHex(64)
          .then((rand2) ->
            rand.should.not.equal(rand2)
          )
      )
      .catch(should.not.exist)

saltPromise = ncrypt.randHex(64)
passwordsPromise = saltPromise
  .then((salt) ->
    promisedHashes = [1..4].map((i) -> ncrypt.hashPw('foobar', salt))
    Promise.all(promisedHashes)
  )

describe 'Password hashing functions', ->
  it 'should always generate the same hash when using the same salt and password', ->
    passwordsPromise.then((hashes) ->
        [last, allEquals] = hashes.reduce(([last, equals], compare) ->
          if not last? or not equals then [compare, equals]
          else [compare, compare == last]
        , [undefined, true])

        allEquals.should.be.exactly(true)
      )
      .catch(should.not.exist)

  it 'should compare as being the same', ->
    passwordsPromise
      .then((passwords) ->
        ncrypt.compare(passwords[0], 'foobar')
      )
      .then((equal) -> equal.should.be.exactly(true))
      .catch(should.not.exist)
