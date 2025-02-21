@description('Virtual Network Name')
param name string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Log Analytics Workspace')
param workspaceId string

var networkSettings = environment == 'dev'
  ? loadJsonContent('../../infra/settings/connectivity/settings-dev.json')
  : loadJsonContent('../../infra/settings/connectivity/settings-prod.json')

@description('Virtual Network')
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = if (networkSettings.create) {
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

resource existingVNet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = if (!networkSettings.create) {
  name: name
  scope: resourceGroup()
}

@description('Network Diagnostic Settings')
resource logAnalyticsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'virtualNetwork-DiagnosticSettings'
  scope: (networkSettings.create) ? virtualNetwork : existingVNet
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: workspaceId
  }
}

@description('Virtual Network Id')
output virtualNetworkId string = (networkSettings.create) ? virtualNetwork.id : existingVNet.id

@description('Virtual Network Subnets')
output virtualNetworkSubnets array = [
  for (subnet, i) in networkSettings.subnets: {
    id: (networkSettings.create) ? virtualNetwork.properties.subnets[i].id : existingVNet.properties.subnets[i].id
    name: (networkSettings.create) ? subnet.name : existingVNet.properties.subnets[i].name
  }
]

@description('Virtual Network Name')
output virtualNetworkName string = (networkSettings.create) ? virtualNetwork.name : existingVNet.name

@description('Network Connections for the Virtual Network Subnets')
resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-10-01-preview' = [
  for (subnet, i) in networkSettings.subnets: {
    name: subnet.name
    location: resourceGroup().location
    tags: networkSettings.tags
    properties: {
      domainJoinType: 'AzureADJoin'
      subnetId: (networkSettings.create) ? virtualNetwork.properties.subnets[i].id : existingVNet.properties.subnets[i].id
    }
  }
]

@description('Network Connections created')
output networkConnections array = [
  for (connection, i) in networkSettings.subnets: {
    id: networkConnection[i].id
    name: networkConnection[i].name
  }
]
