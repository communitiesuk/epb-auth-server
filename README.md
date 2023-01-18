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

## Windows setup
You will need to install `make` and `ruby`.
[Chocolatey](https://chocolatey.org/install) makes this easier.
It is recommended to use [rbenv](https://github.com/ccmywish/rbenv-for-windows) to manage multiple versions of ruby

In PowerShell in Administrative mode, run in order
```shell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install make
choco install 7zip

mkdir "C:\Ruby-on-Windows"
git -C "C:\Ruby-on-Windows" clone "https://github.com/ccmywish/rbenv-for-windows" rbenv

rbenv install 3.1.2
rbenv global 3.1.2
```
You should be able to run Makefile Scripts at this point
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
