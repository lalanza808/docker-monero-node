.PHONY: format help

# Help system from https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

up: ## Build and run the required containers by fetching binaries
	docker-compose -f docker-compose.nocompile.yaml up -d

up-full: ## Build and run the required containers by compiling source
	docker-compose -f docker-compose.compile.yaml up -d

down: ## Stop the containers
	docker-compose -f docker-compose.nocompile.yaml up -d

down-full: ## Stop the containers
	docker-compose -f docker-compose.compile.yaml up -d

logs: ## Get logs from the containers
	docker-compose -f docker-compose.nocompile.yaml up -d

logs-full: ## Get logs from the containers
	docker-compose -f docker-compose.compile.yaml up -d
