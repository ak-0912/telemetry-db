ATLAS        ?= atlas
ATLAS_CONFIG := file://atlas.hcl
ATLAS_ENV    := dev
PSQL         ?= psql

# Override when Postgres is elsewhere (e.g. devcontainer DB on host: localhost:5433).
DATABASE_URL ?= postgres://telemetry:telemetry@localhost:5432/telemetry?sslmode=disable
export DATABASE_URL

.PHONY: db-setup db-apply db-hash db-reset db-drop-atlas migrate-apply

migrate-apply:
	$(ATLAS) migrate apply --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)

db-setup db-apply: migrate-apply

db-hash:
	$(ATLAS) migrate hash --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)

# Removes objects declared in schema.hcl (see Atlas docs). Leaves DB without public unless you recreate it.
db-drop-atlas:
	$(ATLAS) schema clean --env $(ATLAS_ENV) --config $(ATLAS_CONFIG) --auto-approve

# Wipes all rows and tables in public, clears Atlas migration history, reapplies migrations from scratch.
db-reset:
	$(PSQL) "$(DATABASE_URL)" -v ON_ERROR_STOP=1 \
		-c 'DROP SCHEMA IF EXISTS public CASCADE; CREATE SCHEMA public; ALTER SCHEMA public OWNER TO CURRENT_USER; GRANT ALL ON SCHEMA public TO PUBLIC;' \
		-c 'DROP SCHEMA IF EXISTS atlas_schema_revisions CASCADE;'
	$(ATLAS) migrate apply --env $(ATLAS_ENV) --config $(ATLAS_CONFIG)
