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
  ? loadJsonContent('../../deploy/settings/workload/settings.dev.json')
  : loadJsonContent('../../deploy/settings/workload/settings.prod.json')

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
resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = if (settings.computeGallery.create) {
  name: settings.computeGallery.name
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

@description('Dev Center DevBox Definitions')
resource devBoxDefinitions 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-10-01-preview' = [
  for devBoxDefinition in settings.devBoxDefinitions: {
    name: devBoxDefinition.name
    location: resourceGroup().location
    parent: devCenter
    properties: {
      hibernateSupport: devBoxDefinition.hibernateSupport
      imageReference: {
        id: '${resourceId('Microsoft.DevCenter/devcenters/galleries/',devCenter.name,'Default')}/images/${devBoxDefinition.image}'
      }
      sku: {
        name: devBoxDefinition.sku
      }
    }
  }
]

@description('Dev Center Catalogs')
resource devCenterCatalogs 'Microsoft.DevCenter/devcenters/catalogs@2024-10-01-preview' = [
  for catalog in settings.devCenterCatalogs: {
    name: catalog.name
    parent: devCenter
    properties: (catalog.gitHub)
      ? {
          gitHub: {
            uri: catalog.uri
            branch: catalog.branch
            path: catalog.path
          }
          syncType: 'Scheduled'
        }
      : {
          adoGit: {
            uri: catalog.uri
            branch: catalog.branch
            path: catalog.path
          }
          syncType: 'Scheduled'
        }
  }
]

@description('Dev Center Environments')
resource devCenterEnvironments 'Microsoft.DevCenter/devcenters/environmentTypes@2024-10-01-preview' = [
  for environment in settings.environmentTypes: {
    name: environment.name
    parent: devCenter
    properties: {
      displayName: environment.name
    }
  }
]

@description('Dev Center Projects')
resource projects 'Microsoft.DevCenter/projects@2024-10-01-preview' = [
  for project in settings.projects: {
    name: project.name
    location: resourceGroup().location
    identity: {
      type: project.identity.type
    }
    properties: {
      devCenterId: devCenter.id
    }
  }
]

@description('Dev Center Projects Role Assignments')
module roleAssignmentsProjects '../identity/roleAssignmentsResource.bicep' = [
  for (identity,i) in settings.projects: {
    name: identity[i].name
    params: {
      scope: 'subscription'
      principalId: projects[i].identity.principalId
      roles: identity[i].identity.roles
    }
  }
]
