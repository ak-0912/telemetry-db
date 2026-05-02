ATLAS        ?= atlas
ATLAS_CONFIG := file://atlas.hcl
ATLAS_ENV    := dev

# Override when Postgres is elsewhere (e.g. devcontainer DB on host: localhost:5433).
DATABASE_URL ?= postgres://telemetry:telemetry@localhost:5432/telemetry?sslmode=disable
export DATABASE_URL

.PHONY: db-setup db-apply db-hash db-reset db-drop-atlas migrate-apply

migrate-apply:
	$(ATLAS) migrate apply --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)

db-setup db-apply: migrate-apply

db-hash:
	$(ATLAS) migrate hash --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)

db-drop-atlas:
	$(ATLAS) schema clean --env $(ATLAS_ENV) --config $(ATLAS_CONFIG) --auto-approve

db-reset:
	$(ATLAS) schema clean --env $(ATLAS_ENV) --config $(ATLAS_CONFIG) --auto-approve
	$(ATLAS) migrate apply --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)
