@description('The name of the Dev Center resource.')
param name string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('networkConnections')
param networkConnections array

@description('Dev Center settings')
var settings = environment == 'dev'
  ? loadJsonContent('settings/dev/settings.json')
  : loadJsonContent('settings/prod/settings.json')

@description('Dev Center Resource')
resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: settings.tags
  identity: {
    type: settings.identity.type
    userAssignedIdentities: settings.identity.type == 'UserAssigned' ? settings.identity.userAssignedIdentities : null
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: settings.catalogItemSyncEnableStatus
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: settings.microsoftHostedNetworkEnableStatus
    }
    devBoxProvisioningSettings: {
      installAzureMonitorAgentEnableStatus: settings.installAzureMonitorAgentEnableStatus
    }
  }
}

@description('Deploys Network Connections for the Dev Center')
resource vNetAttachment 'Microsoft.DevCenter/devcenters/attachednetworks@2024-10-01-preview' = [
  for connection in networkConnections: {
    name: connection.name
    parent: devCenter
    properties: {
      networkConnectionId: connection.id
    }
  }
]
