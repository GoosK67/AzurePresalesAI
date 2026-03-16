#!/usr/bin/env bash
set -euo pipefail
RG=${1:-rg-rfp-ai}
LOC=${2:-westeurope}
PREFIX=${3:-rfpai}
AOAI_DEPLOY=${4:-gpt4oMini}
AOAI_MODEL=${5:-gpt-4o-mini}
AOAI_VER=${6:-2024-08-06}
INDEX=${7:-rfp-index}

az group create -n "$RG" -l "$LOC" >/dev/null

az deployment group create \
  --resource-group "$RG" \
  --template-file infra/main.bicep \
  --parameters prefix="$PREFIX" location="$LOC" \
               openAiDeploymentName="$AOAI_DEPLOY" \
               openAiModelName="$AOAI_MODEL" \
               openAiModelVersion="$AOAI_VER" \
               searchIndexName="$INDEX"
