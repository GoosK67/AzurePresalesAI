param prefix string
param location string
param tags object = {}

@description('Deployment name for the default chat model')
param deploymentName string

@description('Model name (e.g., gpt-4o-mini)')
param modelName string

@description('Model version (e.g., 2024-08-06)')
param modelVersion string

var name = toLower('${prefix}-aoai')

resource aoai 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  sku: { name: 'S0' }
  kind: 'OpenAI'
  tags: tags
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  name: deploymentName
  parent: aoai
  properties: {
    model: {
      name: modelName
      version: modelVersion
      format: 'OpenAI'
    }
    raiPolicyName: 'Microsoft.Default'
  }
}

output endpoint string = 'https://${name}.openai.azure.com/'
