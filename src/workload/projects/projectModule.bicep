@description('Project name')
param name string

@description('Dev Center Id')
param devCenterId string

@description('Project Catalogs')
param catalogs array

@description('Project Roles')
param roles array

resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    catalogSettings: {
      catalogItemSyncTypes: [
        'ImageDefinition'
        'EnvironmentDefinition'
      ]
    }
    displayName: name
    description: name
    maxDevBoxesPerUser: 5
    devCenterId: devCenterId
  }
}

@description('Dev Center Projects Role Assignments')
module roleAssignmentsProjects '../../identity/roleAssignmentsResource.bicep' = {
  name: name
  params: {
    scope: 'subscription'
    principalId: project.identity.principalId
    roles: roles
  }
}

@description('Project Catalogs')
resource catalog 'Microsoft.DevCenter/projects/catalogs@2024-10-01-preview' = [
  for catalog in catalogs: {
    name: '${project.name}-${catalog.name}'
    parent: project
    properties: {
      gitHub: {
        uri: catalog.uri
        branch: catalog.branch
        path: catalog.path
      }
    }
  }
]
