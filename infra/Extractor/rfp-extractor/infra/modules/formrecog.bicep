
param prefix string
param location string
param tags object = {}

var name = toLower('${prefix}-cog')

resource fr 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  sku: { name: 'S0' }
  kind: 'FormRecognizer'
  tags: tags
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

output endpoint string = 'https://${name}.cognitiveservices.azure.com/'
