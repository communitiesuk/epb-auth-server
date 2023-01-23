# EPB Authentication and Authorisation Server

A Sinatra based web application that is able to authenticate clients to secured 
API endpoints.

## Running the auth server locally

The auth server requires two environment variables to be set: `JWT_ISSUER` and 
`JWT_SECRET`. Corresponding variables **with the same names and values** need 
to be set on the API server that connects to the auth server.

If you are running the server locally it is likely that you will be running it 
alongside another sinatra or rack application. The Makefile runs the server on
port 9090 by default. To start the server on a different port run e.g. 
`bundle exec rackup -p 9393`

To use this most applications use the `EPB_AUTH_SERVER` environment variable.

When you start a server that will make calls to the authentication server, make
sure you also set this environment variable as follows:
`EPB_AUTH_SERVER=http://localhost:9090 make run`

## Makefile Scripts

* `make install`

  Install dependencies and perform any additional setup tasks.

* `make test`

  Run all acceptance, integration, and unit tests.

* `make run`

  Run the auth server, which will be available at `http://localhost:9090`.

* `make format`

  Format source files according to the `.editorconfig` and prettier defaults

* `make db-setup`

  Setup the database (Create > Migrate)

* `make db-teardown`

  Drop the current database.


## Docker image

### Build

To rebuild the Docker image locally, run

`docker build . --tag epb-auth-server`

### Run

#### Docker Desktop

You can run the created image in Docker Desktop by going to **Images** and pressing **Run** in the *Actions* column.
This will create a persistent deployment and has an interface to provide multiple useful options.   

#### CLI

To run the docker image with CLI

`docker run -p {host_port}:80 --name test-epb-auth-service epb-auth-server`

Where *host_port* is a free port you want to use on your host machine to make calls to the API.

If you want docker to communiacte with a containarized instance of PostgreSQL, or another container in general, you will need to link them.

`docker run -p 8000:80 --link {linked_container_id} --name test-epb-auth-service epb-auth-server`
