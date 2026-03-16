
// =====================
// main.bicep – Cegeka RFP Extractor (Azure)
// =====================
@description('Name prefix for all resources (only lowercase letters and numbers).')
param prefix string = 'rfpai'

@description('Deployment location')
param location string = resourceGroup().location

@description('Azure OpenAI model deployment name to create')
param openAiDeploymentName string = 'gpt4oMini'

@description('Azure OpenAI model name')
param openAiModelName string = 'gpt-4o-mini'

@description('Azure OpenAI model version')
param openAiModelVersion string = '2024-08-06'

@description('Search index name to be used by the Function App')
param searchIndexName string = 'rfp-index'

var tags = {
  project: 'rfp-extractor'
}

module storage './modules/storage.bicep' = {
  name: '${prefix}-storage'
  params: {
    prefix: prefix
    location: location
    tags: tags
  }
}

module search './modules/search.bicep' = {
  name: '${prefix}-search'
  params: {
    prefix: prefix
    location: location
    tags: tags
  }
}

module formrecog './modules/formrecog.bicep' = {
  name: '${prefix}-formrecog'
  params: {
    prefix: prefix
    location: location
    tags: tags
  }
}

module openai './modules/ai-openai.bicep' = {
  name: '${prefix}-openai'
  params: {
    prefix: prefix
    location: location
    tags: tags
    deploymentName: openAiDeploymentName
    modelName: openAiModelName
    modelVersion: openAiModelVersion
  }
}

module functionapp './modules/functionapp.bicep' = {
  name: '${prefix}-functionapp'
  params: {
    prefix: prefix
    location: location
    tags: tags
    storageConnectionString: storage.outputs.connectionString
    storageAccountName: storage.outputs.accountName
    inContainer: storage.outputs.inContainer
    outContainer: storage.outputs.outContainer
    formRecognizerEndpoint: formrecog.outputs.endpoint
    openAiEndpoint: openai.outputs.endpoint
    openAiDeploymentName: openAiDeploymentName
    searchEndpoint: search.outputs.endpoint
    searchApiKey: search.outputs.adminKey
    searchIndexName: searchIndexName
  }
}

output storageAccountName string = storage.outputs.accountName
output inContainer string = storage.outputs.inContainer
output outContainer string = storage.outputs.outContainer
output formRecognizerEndpoint string = formrecog.outputs.endpoint
output openAiEndpoint string = openai.outputs.endpoint
output openAiDeploymentName string = openAiDeploymentName
output searchEndpoint string = search.outputs.endpoint
output searchIndexName string = searchIndexName
