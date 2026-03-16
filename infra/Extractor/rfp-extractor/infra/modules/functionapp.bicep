param prefix string
param location string
param tags object = {}

param storageConnectionString string
param inContainer string
param outContainer string

param formRecognizerEndpoint string
param openAiEndpoint string
param openAiDeploymentName string

param searchEndpoint string
param searchApiKey string
param searchIndexName string

var planName = '${prefix}-plan'
var appName  = '${prefix}-func'

resource plan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// Linux Function App (Consumption)
resource app 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'functionapp,linux'
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'Python|3.11'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageConnectionString
        },
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        },
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        },
        {
          name: 'BLOB_IN_CONTAINER'
          value: inContainer
        },
        {
          name: 'BLOB_OUT_CONTAINER'
          value: outContainer
        },
        {
          name: 'FORMRECOGNIZER_ENDPOINT'
          value: formRecognizerEndpoint
        },
        {
          name: 'AOAI_ENDPOINT'
          value: openAiEndpoint
        },
        {
          name: 'AOAI_DEPLOYMENT'
          value: openAiDeploymentName
        },
        {
          name: 'SEARCH_ENDPOINT'
          value: searchEndpoint
        },
        {
          name: 'SEARCH_API_KEY'
          value: searchApiKey
        },
        {
          name: 'SEARCH_INDEX'
          value: searchIndexName
        }
      ]
    }
  }
}

output name string = app.name