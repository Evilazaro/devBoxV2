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
module projectRoleAssignments '../../identity/roleAssignmentsResource.bicep' = {
  name: 'roleAssignments:${project.name}'
  params: {
    scope: 'subscription'
    principalId: project.identity.principalId
    roles: roles
  }
}

@description('Project Catalogs')
module projectCatalogs 'catalogs.bicep' = {
  name: 'catalogs:${project.name}'
  params: {
    projectName: project.name
    catalogs: catalogs
  }
}
