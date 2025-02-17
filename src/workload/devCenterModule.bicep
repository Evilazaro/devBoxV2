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
  ? loadJsonContent('../../deploy/settings/workload/workloadSettings-dev.json')
  : loadJsonContent('../../deploy/settings/workload/workloadSettings-prod.json')

var devBoxDefinitionsSettings = environment == 'dev'
  ? loadJsonContent('../../deploy/settings/workload/devBoxDefinitions-dev.json')
  : loadJsonContent('../../deploy/settings/workload/devBoxDefinitions-prod.json')

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

module roleAssignments '../identity/roleAssignmentsResource.bicep' = {
  name: 'roleAssignments'
  params: {
    scope: 'subscription'
    principalId: devCenter.identity.principalId
    roles: settings.identity.roles
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

@description('Compute Gallery')
resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = {
  name: 'devCenterGallery'
  location: resourceGroup().location
  tags: settings.tags
  properties: {
    description: 'Dev Center Compute Gallery'
  }
}

@description('DevCenter Compute Gallery')
resource devCenterGallery 'Microsoft.DevCenter/devcenters/galleries@2024-10-01-preview' = {
  name: computeGallery.name
  parent: devCenter
  properties: {
    galleryResourceId: computeGallery.id
  }
}

@description('Dev Box Definition')
resource devBoxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview' = [
  for devboxDefinition in devBoxDefinitionsSettings: {
    name: devboxDefinition.name
    location: resourceGroup().location
    parent: devCenter
    tags: devBoxDefinitionsSettings.tags
    properties: {
      imageReference: {
        id: devBoxDefinitionsSettings.default
          ? '${resourceId('Microsoft.DevCenter/devcenters', devCenter.name)}/galleries/default/images/${devBoxDefinitionsSettings.image}'
          : '${resourceId('Microsoft.DevCenter/devcenters', devCenter.name)}/galleries/${devCenterGallery.name}/images/${devBoxDefinitionsSettings.image}'
      }
      hibernateSupport: devboxDefinition.hibernateSupport
      sku: {
        name: devboxDefinition.sku
      }
    }
  }
]
