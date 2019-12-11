.DEFAULT_GOAL := help
SHELL := /bin/bash

.PHONY: help
help:
	@echo "EPB Authentication and Authorisation Server"
	@echo
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: ## Run all codebase tests
	@rake spec

.PHONY: run
run: ## Run the authentication server
	@rackup

.PHONY: install
install: ## Run to install dependancies and perform any setup tasks
	@bundle install
