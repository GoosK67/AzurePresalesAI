
param(
  [Parameter(Mandatory=$true)][string]$SubscriptionId,
  [Parameter(Mandatory=$true)][string]$TenantId,
  [Parameter(Mandatory=$true)][string]$RepoFullName # e.g. org/repo
)

# 1) Create an Entra ID app for GitHub OIDC
az account set --subscription $SubscriptionId
$app = az ad app create --display-name "github-oidc-$($RepoFullName.Replace('/', '-'))" | ConvertFrom-Json
$appId = $app.appId

# 2) Create federated credential (workflow)
az ad app federated-credential create   --id $appId   --parameters @- << JSON
{
  "name": "github-actions",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:$RepoFullName:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
JSON

# 3) Create SP and assign RBAC on subscription (Contributor by default)
az ad sp create --id $appId > $null
az role assignment create   --assignee-object-id $(az ad sp show --id $appId --query id -o tsv)   --assignee-principal-type ServicePrincipal   --role Contributor   --scope "/subscriptions/$SubscriptionId"

Write-Host "Set these GitHub secrets:" -ForegroundColor Green
Write-Host "AZURE_TENANT_ID=$TenantId"
Write-Host "AZURE_SUBSCRIPTION_ID=$SubscriptionId"
Write-Host "AZURE_CLIENT_ID=$appId"
