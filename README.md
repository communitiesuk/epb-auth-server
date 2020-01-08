# EPB Authentication and Authorisation Server

A Sinatra based web application that is able to authenticate clients to secured 
API endpoints.

## Running the auth server locally

If you are running the server locally it is likely that you will be running it 
alongside another sinatra or rack application. To start the server you'll need
to run it on another port.

To start the server on another port run: `bundle exec rackup -p 9393`

To use this most applications use the `AUTH_SERVER` environment variable.

When you start a server that will make calls to the authentication server, make
sure you also set this environment variable as follows:
`AUTH_SERVER=http://localhost:9393 make run`

## Makefile Scripts

* `make install`

  Install dependencies and perform any additional setup tasks.

* `make test`

  Run all acceptance, integration, and unit tests.

* `make run`

  Run the auth server on the default port.

* `make format`

  Format source files according to the `.editorconfig` and prettier defaults

* `make db-setup`

  Setup the database (Create > Migrate)

* `make db-teardown`

  Drop the current database.
