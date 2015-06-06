# Some sort of shop?

The goal with this application is to get familiar with node's backend stack for testing, the tooling, debugging, etc. ~~There will be no UI for this application - it will only the a REST API.~~

Currently using:
* Bluebird for promises, makes asynchronous programming a helluva more enjoyable.
* Mocha as the base testing framework.
* Should.js matchers for noyce testing dsl.
* Supertest for testing the REST api (integration tests).
* nodemon as the application reloader. Can't live without one.
* ExpressJS framework. Simple, extensible, I like that.
* node-postgres as the database client with a wrapper to use promises instead of "oh my gawd a pyramid".
* AngularJs

TODO:
* Block user from going to certain routes when not logged in/when logged in.
