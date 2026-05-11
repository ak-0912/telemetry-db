// Atlas project config: declarative schema (schema.hcl) + versioned migrations (migrations/).
// Set DATABASE_URL to override the fallback below.  The Makefile exports it
// automatically (host: 127.0.0.1:5433, container: db:5432).

locals {
  database_url = getenv("DATABASE_URL") != "" ? getenv("DATABASE_URL") : "postgres://telemetry:telemetry@127.0.0.1:5433/telemetry?sslmode=disable"
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
