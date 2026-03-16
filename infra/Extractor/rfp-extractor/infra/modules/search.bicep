param prefix string
param location string
param tags object = {}

var searchName = toLower('${prefix}-search')

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchName
  location: location
  sku: { name: 'basic' }
  tags: tags
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    disableLocalAuth: false
  }
}

var keys = search.listAdminKeys()

output endpoint string = 'https://${searchName}.search.windows.net'
output adminKey string = keys.primaryKey