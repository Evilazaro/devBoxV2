@description('Virtual Network Name')
param name string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

var networkSettings = environment == 'dev'
  ? loadJsonContent('settings/dev/networkSettings.json')
  : loadJsonContent('settings/prod/networkSettings.json')

@description('Virtual Network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: resourceGroup().location
  tags: networkSettings.tags
  properties: {
    addressSpace: {
      addressPrefixes: networkSettings.addressPrefixes
    }
    subnets: [
      for subnet in networkSettings.subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.properties.addressPrefix
        }
      }
    ]
  }
}

@description('Network Connections for the Virtual Network Subnets')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' = [
  for (subnet, i) in networkSettings.subnets: {
    name: subnet.name
    location: resourceGroup().location
    tags: networkSettings.tags
    properties: {
      domainJoinType: 'AzureADJoin'
      subnetId: virtualNetwork.properties.subnets[i].id
    }
  }
]

@description('Network Connections created')
output networkConnections array = [
  for (connection,i) in networkSettings.subnets: {
    id: networkConnection[i].id
    name: networkConnection[i].name
  }
]
