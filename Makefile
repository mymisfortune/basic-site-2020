.DEFAULT_GOAL := help
SHELL := /usr/bin/env bash

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: validate

validate:  ## Usage: make validate
	docker-compose run --rm terraform " \
		terraform init -backend=false && \
		terraform validate . \
	"

format: ## Usage: make format
	docker-compose run --rm terraform " \
		terraform fmt -recursive -diff . \
	"
