.DEFAULT_GOAL := help
SHELL := /bin/bash

PAAS_API ?= api.london.cloud.service.gov.uk
PAAS_ORG ?= mhclg-energy-performance
PAAS_SPACE ?= ${STAGE}

define check_space
	@echo "Checking PaaS space is active..."
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@[ $$(cf target | grep -i 'space' | cut -d':' -f2) = "${PAAS_SPACE}" ] || (echo "${PAAS_SPACE} is not currently active cf space" && exit 1)
endef

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
install: ## Run to install dependancies and perform any setup tasks
	@bundle install
	$(MAKE) db-setup

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
format: ## Format code according to editorconfig and prettier defaults
	@bundle exec rbprettier --write `find . -name '*.rb'` *.ru Gemfile

.PHONY: generate-manifest
generate-manifest: ## Generate manifest file for PaaS
	$(if ${DEPLOY_APPNAME},,$(error Must specify DEPLOY_APPNAME))
	$(if ${PAAS_SPACE},,$(error Must specify PAAS_SPACE))
	@scripts/generate-paas-manifest.sh ${DEPLOY_APPNAME} ${PAAS_SPACE} > manifest.yml

.PHONY: deploy-app
deploy-app: ## Deploys the app to PaaS
	$(call check_space)
	$(if ${DEPLOY_APPNAME},,$(error Must specify DEPLOY_APPNAME))

	@$(MAKE) generate-manifest

	cf v3-apply-manifest -f manifest.yml

	cf set-env "${DEPLOY_APPNAME}" EPB_UNLEASH_URI "${EPB_UNLEASH_URI}"
	cf set-env "${DEPLOY_APPNAME}" STAGE "${PAAS_SPACE}"
	cf set-env "${DEPLOY_APPNAME}" JWT_ISSUER "${JWT_ISSUER}"
	cf set-env "${DEPLOY_APPNAME}" JWT_SECRET "${JWT_SECRET}"
	cf set-env "${DEPLOY_APPNAME}" URL_PREFIX "/auth"

	cf v3-zdt-push "${DEPLOY_APPNAME}" --wait-for-deploy-complete
