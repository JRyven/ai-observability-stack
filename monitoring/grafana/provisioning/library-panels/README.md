# Grafana Library Panels

Reusable Grafana library panels for monitoring stack dashboards. Library panels enable:
- **Consistency:** Same panel definition across multiple dashboards
- **Maintainability:** Edit once, update all dashboards using the panel
- **Reusability:** Duplicate panels for variations without starting from scratch
- **Version control:** Track panel changes in Git

## Naming Convention

Library panels follow a `{exporter}-{metric-category}-{measurement-unit}` naming pattern:

| Prefix | Source | Metrics | Examples |
|--------|--------|---------|----------|
| `node-` | node_exporter | CPU, memory, disk, network, load, temperatures | `node-cpu-usage-percent.json`, `node-load-average-1m.json` |
| `rocm-` | ROCm GPU exporter | AMD GPU utilization, temperature, VRAM | `rocm-gpu-utilization-percent.json`, `rocm-gpu-temperature-celsius.json` |
| `ollama-` | LLM runtime Prometheus metrics | Ollama token counts from response metadata | `ollama-token-counts-total.json` |

This convention enables quick identification of the exporter source and ensures consistent organization as new panels are added.

## Available Panels

### Node Exporter Panels (5)

1. **node-cpu-usage-percent.json** - CPU Usage % (average across all cores)
   - Metric: `node_cpu_seconds_total`
   - Formula: `100 - (avg by (instance) (irate(...[5m])) * 100)`
   - Thresholds: Green <50%, Yellow 50-80%, Red >80%

2. **node-load-average-1m.json** - Load Average (1 minute)
   - Metric: `node_load1`
   - Thresholds: Green <4, Yellow 4-8, Red >8

3. **node-memory-used-percent.json** - Memory Used %
   - Metric: `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`
   - Formula: `(1 - available / total) * 100`
   - Thresholds: Green <70%, Yellow 70-90%, Red >90%

4. **node-cpu-temperature-celsius.json** - CPU Temperature
   - Metric: `node_hwmon_temp_celsius{chip=~"k10temp.*|coretemp.*"}`
   - Thresholds: Green <40°C, Yellow 40-70°C, Orange 70-85°C, Red >85°C

5. **node-gpu-temperature-celsius.json** - GPU Temperature (node_exporter hwmon)
   - Metric: `node_hwmon_temp_celsius{chip=~".*(gpu|amdgpu|radeon|nvidia).*"}`
   - Thresholds: Green <40°C, Yellow 40-60°C, Orange 60-75°C, Red >75°C

### ROCm GPU Panels (3)

6. **rocm-gpu-utilization-percent.json** - ROCm GPU Utilization %
   - Metric: `rocm_gpu_utilization_percent`
   - Range: 0-100%
   - Thresholds: Green <20%, Yellow 20-60%, Red >90%

7. **rocm-gpu-temperature-celsius.json** - ROCm GPU Temperature
   - Metric: `rocm_gpu_temperature_celsius`
   - Thresholds: Blue <40°C, Green 40°C, Yellow 60°C, Orange 75°C, Red >85°C

8. **rocm-gpu-vram-used-mb.json** - ROCm GPU VRAM Used
   - Metric: `rocm_gpu_vram_used_mb * 1024 * 1024`
   - Unit: Bytes (displays as MiB/GiB)
   - Thresholds: Green <16GB, Yellow 16-28GB, Red >28GB

### Ollama Token Panels (1)

9. **ollama-token-counts-total.json** - Ollama Token Counts
   - Metric: `llm_ollama_tokens_total`
   - Formula: `sum by (direction) (llm_ollama_tokens_total)`
   - Source: LLM runtime `/metrics` endpoint on the configured exporter target

## Using Library Panels in Dashboards

### In Grafana UI
1. Navigate to **Dashboards** → **New** → **New Dashboard**
2. Click **Add Panel** → **Library Panels**
3. Search for panel by name (e.g., "CPU Usage")
4. Click panel to add to dashboard
5. Customize time range, size, or queries if needed
6. Save dashboard

### In Dashboard JSON
Reference a library panel by its UID:

```json
{
  "type": "stat",
  "libraryPanel": {
    "name": "CPU Usage % (avg)",
    "uid": "node-cpu-usage"
  },
  "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
}
```

### Creating Variations
1. Add library panel to dashboard
2. Click **Edit** on the panel
3. Click **Unlink library panel** (top-right)
4. Modify the panel (e.g., change thresholds, instance filter)
5. Save as new library panel with descriptive name

## Management

### Adding New Panels
1. Create JSON file in `library-panels/` following naming convention: `{exporter}-{metric}-{unit}.json`
   - Use `node-` prefix for node_exporter metrics
   - Use `rocm-` prefix for ROCm GPU metrics
   - Use `ollama-` prefix for LLM runtime/Ollama metrics
   - Use lowercase with hyphens (e.g., `node-disk-usage-percent.json`)
2. Include required fields:
   - `uid`: Unique identifier matching filename without extension (e.g., `node-disk-usage`)
   - `title`: Display name
   - `type`: Panel type (timeseries, stat, gauge, etc.)
   - `targets`: PromQL queries
   - `fieldConfig`: Units, thresholds, formatting
3. Test in Grafana before committing
4. Document in this README

### Versioning
- **version field:** Increment when modifying panel logic or thresholds
- **schemaVersion:** Keep at 38 (current Grafana standard)
- Track changes in Git commit messages

### Backup & Sync
Library panels are provisioned from this directory. Always:
- Commit changes to Git
- Test modified panels in Grafana
- Document breaking changes in README

## Dashboard Examples

### "Infrastructure Overview" Dashboard
Uses: CPU Usage, Load Average, Memory Used, CPU Temperature

### "GPU Monitoring" Dashboard
Uses: ROCm GPU Utilization, Temperature, VRAM Used

### "Host Metrics - Comprehensive" Dashboard
Uses: All Node Exporter + ROCm panels (10 total)

## Troubleshooting

**Panel shows "No Data"**
- Verify Prometheus targets are scraping metrics
- Check PromQL query in panel (click **Edit** → **Queries**)
- Ensure instance labels match your target labels

**Panel thresholds too strict/loose**
- Edit library panel JSON, adjust `thresholds.steps` values
- Update panel in all dashboards (automatic if using library panel reference)

**Can't find library panel in UI**
- Verify file exists in `/etc/grafana/provisioning/library-panels/`
- Restart Grafana: `docker restart grafana`
- Check Grafana logs: `docker logs grafana`

## Related Documentation

- [Prometheus Configuration](../prometheus/prometheus.md)
- [Grafana Dashboards](../grafana/grafana.md)
- [Monitoring Stack Architecture](../abstract.md)
