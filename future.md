# Future Improvements

## Security
- [ ] Move DB credentials to an external secret manager (Sealed Secrets / External Secrets Operator)
- [ ] Add a NetworkPolicy restricting Postgres ingress to only telemetry workloads

## Helm Chart
- [ ] Add default CPU/memory resource requests and limits for Postgres and the migrate Job
- [ ] Add PodDisruptionBudget for Postgres
- [ ] Support TLS connections between clients and Postgres (cert-manager + pg_hba.conf)
- [ ] Add Prometheus ServiceMonitor / PodMonitor for postgres_exporter sidecar

## Schema & Migrations
- [ ] Add partitioning on `created_at` for time-series query performance
- [ ] Add a retention / data-pruning CronJob (e.g. delete rows older than N days)
- [ ] Add a `db-seed` Makefile target with sample data for local development

## Observability
- [ ] Deploy postgres_exporter sidecar for Postgres metrics
- [ ] Add backup strategy (pg_dump CronJob or WAL-based with pgBackRest / Barman)

## CI/CD
- [ ] Add a CI step that runs `atlas migrate lint` on PRs
- [ ] Add `helm template | kubeval` or `kubeconform` validation in CI
