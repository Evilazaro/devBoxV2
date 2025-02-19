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

@description('Dev Center ID')
output devCenterId string = devCenter.id

@description('Dev Center Name')
output devCenterName string = devCenter.name

module roleAssignments '../identity/roleAssignmentsResource.bicep' = {
  name: 'roleAssignments'
  scope: resourceGroup()
  params: {
    scope: 'subscription'
    principalId: devCenter.identity.principalId
    roles: settings.identity.roles
  }
}

@description('Dev Center Role Assignments')
output roleAssignments object = roleAssignments.outputs

@description('Deploys Network Connections for the Dev Center')
module vNetAttachment 'configuration/networkConnections.bicep'= {
  name: 'vNetAttachments'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.name
    networkConnections: networkConnections
  }
}

@description('Network Connections')
output vNetAttachments array = [for connection in networkConnections: {
  id: vNetAttachment.outputs.vNetAttachments[connection.name].id
  name: connection.name
}]

@description('Compute Gallery')
resource computeGallery 'Microsoft.Compute/galleries@2024-03-03' = if (settings.computeGallery.create) {
  name: settings.computeGallery.name
  location: resourceGroup().location
  tags: settings.computeGallery.tags
  properties: {
    description: 'Dev Center Compute Gallery'
  }
}

@description('Compute Gallery ID')
output computeGalleryId string = computeGallery.id

@description('Compute Gallery Name')
output computeGalleryName string = computeGallery.name

@description('DevCenter Compute Gallery')
resource devCenterGallery 'Microsoft.DevCenter/devcenters/galleries@2024-10-01-preview' = {
  name: computeGallery.name
  parent: devCenter
  properties: {
    galleryResourceId: computeGallery.id
  }
  dependsOn: [
    roleAssignments
  ]
}

@description('Dev Center DevBox Definitions')
module devBoxDefinitions 'configuration/devboxDefinitions.bicep' = {
  name: 'devBoxDefinitions'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.name
    definitions: settings.devBoxDefinitions
  }
}
@description('Dev Center DevBox Definitions')
output devBoxDefinitions array = [for definition in settings.devBoxDefinitions: {
  id: devBoxDefinitions.outputs.devBoxDefinitions[definition.name].id
  name: definition.name
}]


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

@description('Dev Center Catalogs')
output devCenterCatalogs array = [
  for catalog in settings.devCenterCatalogs: {
    id: devCenterCatalogs[catalog.name].id
    name: catalog.name
  }
]

@description('Dev Center Environments')
resource devCenterEnvironments 'Microsoft.DevCenter/devcenters/environmentTypes@2024-10-01-preview' = [
  for environment in settings.environmentTypes: {
    name: environment.name
    parent: devCenter
    tags: environment.tags
    properties: {
      displayName: environment.name
    }
  }
]

@description('Dev Center Environments')
output devCenterEnvironments array = [
  for environment in settings.environmentTypes: {
    id: devCenterEnvironments[environment.name].id
    name: environment.name
  }
]

@description('Dev Center Projects')
module projects 'projects/projectModule.bicep' = [
  for project in settings.projects: {
    name: '${project.name}-project'
    scope: resourceGroup()
    params: {
      name: project.name
      catalogs: project.catalogs
      devCenterId: devCenter.id
      roles: project.identity.roles
      environments: project.environments
      devBoxPools: project.pools
      tags: project.tags
    }
    dependsOn: [
     vNetAttachment
     devBoxDefinitions
    ]
  }
]

@description('Dev Center Projects')
output projects array = [
  for (project,i) in settings.projects: {
    id: projects[i].outputs.id
    name: project.name
  }
]
