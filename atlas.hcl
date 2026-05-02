// Atlas project config: declarative schema (schema.hcl) + versioned migrations (migrations/).
// DATABASE_URL overrides the default (matches root docker-compose.yml).

locals {
  database_url = getenv("DATABASE_URL") != "" ? getenv("DATABASE_URL") : "postgres://telemetry:telemetry@localhost:5432/telemetry?sslmode=disable"
}

env "dev" {
  url = local.database_url
  dev = "docker://postgres/16/dev?search_path=public"

  schema {
    src = "file://schema.hcl"
  }

  migration {
    dir = "file://migrations"
  }
}
