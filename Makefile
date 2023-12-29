.DEFAULT_GOAL := help
SHELL := /bin/bash


.PHONY: help
help:
	@echo "EPB Authentication and Authorisation Server"
	@echo
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: ## Run all codebase tests
	@bundle exec rake spec

.PHONY: run
run: ## Run the authentication server
	$(if ${JWT_ISSUER},,$(error Must specify JWT_ISSUER))
	$(if ${JWT_SECRET},,$(error Must specify JWT_SECRET))
	@bundle exec rackup -p 9090

.PHONY: install
install: ## Run to install dependencies and perform any setup tasks
	@bundle install
	$(MAKE) db-setup ENV=$$ENV

.PHONY: db-setup
db-setup: ## Run to create and populate test dbs
	@echo ">>>>> Creating DB"
	@bundle exec rake db:create
	@echo ">>>>> Migrating DB"
	@bundle exec rake db:migrate
	@echo ">>>>> Populating Test DB"
	@bundle exec rake db:test:prepare

.PHONY: db-teardown
db-teardown: ## Run to tear down test dbs
	@echo ">>>>> Dropping DBs"
	@bundle exec rake db:drop

.PHONY: db-create-migration
db-create-migration: ## Run to create a new migration append NAME=
	$(if ${NAME},,$(error Must specify NAME))
	@bundle exec rake db:create_migration NAME=${NAME}

.PHONY: format
format:
	@bundle exec rubocop --autocorrect --format offenses || true

.PHONY: lint-api-spec
lint-api-spec:
	@npx spectral lint config/apidoc.yml -r ./.spectral.yaml
