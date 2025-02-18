@description('Project name')
param name string

@description('Dev Center Id')
param devCenterId string

@description('Project Catalogs')
param catalogs array

@description('Project Roles')
param roles array

@description('Environments')
param environments array

@description('DevBox Pools')
param devBoxPools array

@description('Project Tags')
param tags object

resource project 'Microsoft.DevCenter/projects@2024-10-01-preview' = {
  name: name
  location: resourceGroup().location
  tags: tags
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
  name: '${project.name}-roleAssignments'
  params: {
    scope: 'subscription'
    principalId: project.identity.principalId
    roles: roles
  }
}

@description('Project Catalogs')
module projectCatalogs 'catalogs.bicep' = {
  name: '${project.name}-catalogs'
  params: {
    projectName: project.name
    catalogs: catalogs
  }
}

@description('Project Environments')
resource projectEnvironments 'Microsoft.DevCenter/projects/environmentTypes@2024-10-01-preview' = [
  for environment in environments: {
    name: environment.name
    parent: project
    tags: environment.tags
    properties: {
      displayName: environment.name
      deploymentTargetId: subscription().id
      status: 'Enabled'
      creatorRoleAssignment: {
        roles: toObject(environment.roles, role => role.id, role => role.properties)
      }
    }
  }
]

@description('Project DevBox Pools')
module projectDevBoxPools 'devboxPools.bicep' = {
  name: '${project.name}-devBoxPools'
  params: {
    projectName: project.name
    pools: devBoxPools
  }
}
