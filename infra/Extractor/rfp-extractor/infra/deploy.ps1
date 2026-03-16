param(
    [string]$ResourceGroup = "rg-rfp-ai",
    [string]$Location = "westeurope",
    [string]$Prefix = "rfpai",
    [string]$OpenAIDeployment = "gpt4oMini",
    [string]$OpenAIModel = "gpt-4o-mini",
    [string]$OpenAIModelVersion = "2024-08-06",
    [string]$SearchIndex = "rfp-index"
)

az group create -n $ResourceGroup -l $Location | Out-Null

az deployment group create `
  --resource-group $ResourceGroup `
  --template-file infra/main.bicep `
  --parameters prefix=$Prefix location=$Location `
               openAiDeploymentName=$OpenAIDeployment `
               openAiModelName=$OpenAIModel `
               openAiModelVersion=$OpenAIModelVersion `
               searchIndexName=$SearchIndex
