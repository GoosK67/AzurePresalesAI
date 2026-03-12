
# Cegeka AI Platform – GitHub Project

This repository contains everything to **deploy, configure and test** the Azure AI Platform, plus **weekly workshop automation**.

- Infra lives under `infra/azure-ai-platform` (Bicep modules + README)
- CI, deploy workflows and workshop reminders under `.github/workflows`
- Docs under `docs/` (agenda + runbooks)

## Getting started
1. Configure GitHub OIDC with Azure: `./scripts/configure-oidc-azure.ps1`
2. Add repository secrets: `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_CLIENT_ID`.
3. Run **Deploy DEV** workflow.
4. Join the **Wednesday workshop** – issues are created automatically.
