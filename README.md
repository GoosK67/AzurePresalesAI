# BidBrain of BidCraft
# Cegeka Azure AI Platform (OpenAI + Claude + watsonx + AKS)

This repository contains a **modular Bicep project** to deploy an enterprise‑grade, zero‑trust AI platform on Azure:

- Azure OpenAI (private endpoint) with GPT‑4o‑mini + text‑embedding‑3‑large
- Anthropic Claude via Azure AI Foundry Model Catalog (Sonnet 4.6 default)
- IBM watsonx.ai (dual‑path: AKS direct outbound + Function App proxy)
- Hybrid AKS cluster (private API server)
- Azure Storage, Cosmos DB (SQL), Cognitive Search (all private)
- Private DNS zones, Key Vault, Function App Premium with VNet Integration

> Region: **westeurope**.  Base name: **aiplat** (override in `parameters.json`).

---

## Repository structure

```
azure-ai-platform/
├─ platform.bicep
├─ parameters.json
├─ deploy.ps1
├─ deploy.sh
└─ modules/
   ├─ network.bicep
   ├─ privateDns.bicep
   ├─ storage.bicep
   ├─ cosmos.bicep
   ├─ search.bicep
   ├─ functionapp.bicep
   ├─ openai.bicep
   ├─ anthropic.bicep
   ├─ watsonx.bicep
   └─ privateEndpoints.bicep
```

---

## Quick start

1) Login and select the subscription
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

2) (Optional) Edit `parameters.json` for `baseName` and `location`.

3) Deploy (PowerShell on Windows)
```powershell
./deploy.ps1 -ResourceGroup rg-ai-foundry -Location westeurope
```

   or (bash on macOS/Linux)
```bash
sh deploy.sh rg-ai-foundry westeurope
```

This will:
- Create the resource group (if missing)
- Deploy VNet + subnets + Private DNS
- Deploy Storage/Cosmos/Search (private only)
- Deploy Function App (Premium) with VNet integration
- Deploy Azure OpenAI (PE) + model deployments
- Deploy Anthropic Claude (Foundry) deployment
- Deploy watsonx proxy + Key Vault
- Deploy AKS (private API) and all Private Endpoints

---

## Architecture (ASCII)
```
Azure Subscription
  └─ VNet 10.10.0.0/16
      ├─ snet-app   (AKS + Function App)
      ├─ snet-data  (PaaS data services)
      └─ snet-pe    (Private Endpoints)

Private DNS Zones:
  - privatelink.blob.core.windows.net
  - privatelink.documents.azure.com
  - privatelink.search.windows.net
  - privatelink.openai.azure.com

Services (private only):
  - Azure OpenAI (PE) + deployments: gpt-4o-mini, text-embedding-3-large
  - Cosmos DB (SQL) (PE)
  - Cognitive Search (PE)
  - Storage Account (Blob) (PE)

AI Providers:
  - Anthropic Claude (Foundry deployment)
  - IBM watsonx.ai (dual path: AKS direct + Function Proxy with Key Vault)

Compute:
  - AKS (private API) — Standard_D4as_v5, Azure CNI
  - Function App Premium (EP1) with VNet Integration
```

---

## IAM / RBAC (minimum)

- Resource Group: **Owner/Contributor** for platform administrators
- Azure OpenAI: **Cognitive Services OpenAI User** for calling deployments
- AKS: **Azure Kubernetes Service RBAC Cluster Admin** (bootstrap)
- Key Vault (watsonx):
  - **Key Vault Secrets Officer** (admin)
  - **Key Vault Secrets User** (Function App MI / AKS Workload Identity)

---

## Troubleshooting

- **Private DNS resolution fails** → Verify `privateDns.bicep` execution and VNet links; run `nslookup` against the `privatelink.*` zones.
- **AKS cannot reach PaaS** → Ensure pods run with proper identity and that private endpoints exist; confirm subnet association (`snet-pe`).
- **OpenAI calls fail** → Check that public network access is disabled and private endpoint/DNS zone are created; confirm model deployments exist.
- **Claude deployment fails** → Ensure Foundry access is enabled for your subscription and Claude models are available to your billing region.
- **watsonx 401/403** → Ensure IBM Cloud API key is in Key Vault and the proxy exchanges it for IAM bearer tokens before calling watsonx endpoints.

---

## Notes

- This repository is a baseline. Add Azure Policy assignments to enforce private networking and disable public access across services.
- Consider adding NAT Gateway / Azure Firewall for deterministic outbound egress from AKS/Functions.
- Add monitoring (LA Workspace, Diagnostics) as needed for production.

