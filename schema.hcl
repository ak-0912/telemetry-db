schema "public" {
}

table "telemetry" {
  schema = schema.public

  column "id" {
    null = false
    type = bigint
    identity {
      generated = BY_DEFAULT
      start     = 1
      increment = 1
    }
  }

  column "metric_name" {
    null = false
    type = text
  }

  column "gpu_id" {
    null = false
    type = text
  }

  column "device" {
    null = false
    type = text
  }

  column "uuid" {
    null = false
    type = text
  }

  column "model_name" {
    null = false
    type = text
  }

  column "host_name" {
    null = false
    type = text
  }

  column "value" {
    null = false
    type = float8
  }

  column "labels_raw" {
    null = false
    type = text
  }

  column "processed_at_unix_nano" {
    null = false
    type = bigint
  }

  column "created_at" {
    null    = false
    type    = timestamptz
    default = sql("now()")
  }

  primary_key {
    columns = [column.id]
  }

  index "idx_telemetry_uuid" {
    columns = [column.uuid]
  }

  index "idx_telemetry_gpu_id" {
    columns = [column.gpu_id]
  }

  index "idx_telemetry_host_name" {
    columns = [column.host_name]
  }
}
