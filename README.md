# AI Observability Monitoring Stack

This repository contains a Docker Compose based monitoring stack for local or self-hosted AI infrastructure. It provides Prometheus, Alertmanager, Grafana provisioning, and example dashboards/panels for common infrastructure, GPU, storage, and LLM telemetry metrics.

The repository is intended as a generic starting point. Replace placeholder targets and metric names with the exporters used in your own environment.

## Included services

- **Prometheus** for metric scraping and alert rule evaluation
- **Alertmanager** for alert routing
- **Grafana** for dashboards and provisioned panels
- **Portainer** as an optional local container-management UI

## Expected metric sources

The default configuration includes examples for:

- Prometheus self-monitoring
- Grafana and Alertmanager metrics
- `node_exporter` host metrics
- GPU exporter metrics, such as ROCm-compatible GPU metrics
- LLM runtime/exporter token counters
- Object-storage exporter metrics, such as MinIO-compatible metrics
- Generic backup-job metrics

These examples are intentionally generic. Disable jobs you do not use, or update `monitoring/prometheus/prometheus.yml` to match your exporter hosts, ports, labels, and metric names.

## Requirements

- Docker and Docker Compose
- Optional: `promtool` for Prometheus config/rule validation
- Exporters for whichever targets you enable

## Quickstart

```bash
cp .env.example .env
# Edit .env and monitoring/prometheus/prometheus.yml for your local targets.
bash scripts/verify.sh
docker compose -f monitoring/docker-compose.yml up -d
```

Grafana will be available at `http://localhost:3000` unless you change the port mapping. Set `GRAFANA_ADMIN_PASSWORD` in `.env` before starting the stack.

## Configuration notes

- Prometheus scrape targets live in `monitoring/prometheus/prometheus.yml`.
- Alerting rules live in `monitoring/prometheus/rules/`.
- Grafana datasource and dashboard provisioning live in `monitoring/grafana/provisioning/`.
- Library panel examples live in `monitoring/grafana/provisioning/library-panels/`.

## Validation

Run:

```bash
bash scripts/verify.sh
```

The script performs repository-safety checks and, when `promtool` is installed, validates Prometheus configuration and rule files. If `promtool` is not installed, the Prometheus lint step is skipped with a clear message.

## Public repository hygiene

Before publishing or accepting outside contributions, verify that the repository does not contain:

- private IP addresses or domains
- local machine paths
- usernames or hostnames from a private environment
- secrets, keys, tokens, or credentials
- generated logs or environment-specific data

If sensitive files were ever committed, removing them from the current tree is not enough. Rewrite Git history with a tool such as `git filter-repo` or BFG, then rotate any exposed credentials.
