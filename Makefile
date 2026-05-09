ATLAS        ?= atlas
PSQL         ?= psql

# Compose file for local Postgres (repo has no root docker-compose.yml).
COMPOSE_FILE ?= .devcontainer/docker-compose.yml
COMPOSE      ?= docker compose -f $(COMPOSE_FILE)

# DATABASE_URL: host "db" only resolves inside the devcontainer Compose network.
# On your laptop/host, use the published port (5433 in .devcontainer/docker-compose.yml).
# Override anytime: DATABASE_URL=postgres://... make db-reset
ifeq ($(wildcard /.dockerenv),)
DATABASE_URL ?= postgres://telemetry:telemetry@127.0.0.1:5433/telemetry?sslmode=disable
else
DATABASE_URL ?= postgres://telemetry:telemetry@db:5432/telemetry?sslmode=disable
endif
export DATABASE_URL

ATLAS_FLAGS := --env dev --config file://atlas.hcl

.DEFAULT_GOAL := help

.PHONY: help db-up db-down db-apply db-setup db-status db-diff db-lint db-hash db-reset db-drop-atlas db-troubleshoot

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z][a-zA-Z0-9_-]*:.*?## / {printf "  %-18s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "DATABASE_URL (auto-default): $(DATABASE_URL)"

db-troubleshoot: ## Commands when port 5433 is busy or hostname db fails
	@echo "=== Port 5433 already allocated ==="
	@echo "List containers publishing 5433:"
	@echo "  docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep 5433"
	@echo "Stop this project's stack:"
	@echo "  $(COMPOSE) down"
	@echo "Stop a specific container:"
	@echo "  docker stop <container_name>"
	@echo ""
	@echo "=== psql: could not translate host name \"db\" ==="
	@echo "Run make from inside the VS Code devcontainer, or on the host run:"
	@echo "  DATABASE_URL=postgres://telemetry:telemetry@127.0.0.1:5433/telemetry?sslmode=disable make db-reset"

db-up: ## Start Postgres (and deps) via devcontainer compose file
	$(COMPOSE) up -d db

db-down: ## Stop stack defined in $(COMPOSE_FILE)
	$(COMPOSE) down

db-apply db-setup: ## Apply pending migrations
	$(ATLAS) migrate apply $(ATLAS_FLAGS)

db-status: ## Show pending and applied migrations
	$(ATLAS) migrate status $(ATLAS_FLAGS)

db-diff: ## Generate a new migration from schema.hcl
	$(ATLAS) migrate diff $(ATLAS_FLAGS)

db-lint: ## Lint the latest migration
	$(ATLAS) migrate lint --latest 1 $(ATLAS_FLAGS)

db-hash: ## Recompute migrations/atlas.sum
	$(ATLAS) migrate hash $(ATLAS_FLAGS)

db-drop-atlas: ## Drop schema objects declared in schema.hcl
	$(ATLAS) schema clean $(ATLAS_FLAGS) --auto-approve

db-reset: ## Wipe public schema, drop atlas history, reapply migrations
	$(PSQL) "$(DATABASE_URL)" -v ON_ERROR_STOP=1 \
		-c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public; ALTER SCHEMA public OWNER TO CURRENT_USER; GRANT ALL ON SCHEMA public TO PUBLIC;' \
		-c 'DROP SCHEMA IF EXISTS atlas_schema_revisions CASCADE;'
	$(MAKE) db-apply
