
#!/usr/bin/env bash
set -euo pipefail
RG=${1:-rg-ai-foundry}
LOC=${2:-westeurope}
TEMPLATE=${3:-platform.bicep}
PARAMS=${4:-parameters.json}
az group create -n "$RG" -l "$LOC" >/dev/null
az deployment group create \
  --resource-group "$RG" \
  --template-file "$TEMPLATE" \
  --parameters @"$PARAMS"
