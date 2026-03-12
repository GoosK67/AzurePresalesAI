
#!/usr/bin/env bash
set -euo pipefail
cd infra/azure-ai-platform
az bicep version || az bicep install
az bicep build --file platform.bicep
