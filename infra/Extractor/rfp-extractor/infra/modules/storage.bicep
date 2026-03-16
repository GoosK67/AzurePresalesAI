param prefix string
param location string
param tags object = {}

var accountName = toLower('${prefix}st')

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: accountName
  location: location
  tags: tags
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: st
}

resource contIn 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'rfp-in'
  parent: blob
  properties: { publicAccess: 'None' }
}

resource contOut 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'rfp-out'
  parent: blob
  properties: { publicAccess: 'None' }
}

var keys = st.listKeys()
var conn = 'DefaultEndpointsProtocol=https;AccountName=${accountName};AccountKey=${keys.keys[0].value};EndpointSuffix=${environment().suffixes.storage}'

output connectionString string = conn
output accountName string = accountName
output inContainer string = 'rfp-in'
output outContainer string = 'rfp-out'
``