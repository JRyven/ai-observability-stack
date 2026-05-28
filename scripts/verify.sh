#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FORBIDDEN_PATTERN='(BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{20,}|/Users/|/home/[A-Za-z0-9._-]+|[A-Za-z0-9._%+-]+\.mayrose\.top|id_mayrose_ubuntu|passportphoto|voyante|sequencer)'

if command -v rg >/dev/null 2>&1; then
  if rg -n "$FORBIDDEN_PATTERN" . \
    --glob '!.git/**' \
    --glob '!*.png' \
    --glob '!*.jpg' \
    --glob '!*.jpeg' \
    --glob '!*.svg' \
    --glob '!*.lock' \
    --glob '!scripts/verify.sh'; then
    echo "verify: forbidden private/sensitive markers found"
    exit 1
  fi
else
  echo "ripgrep not installed; skipping repository safety scan"
fi

if ! command -v promtool >/dev/null 2>&1; then
  echo "promtool not installed; skipping Prometheus lint"
else
  promtool check config monitoring/prometheus/prometheus.yml
  promtool check rules monitoring/prometheus/rules/*.yml
fi

python3 - <<'PY'
import json
from pathlib import Path

for path in Path('.').rglob('*.json'):
    if '.git' in path.parts:
        continue
    with path.open(encoding='utf-8') as fh:
        json.load(fh)
print('json: pass')
PY

echo "verify: pass"
