@description('The name of the Dev Center resource.')
@maxLength(63)
param name string

@description('Location for the Dev Center resource.')
param location string

@description('Dev Center settings')
param settings object

@description('Dev Center Resource')
module devCenter './devCenterResource.bicep' = {
  name: 'devCenter'
  scope: resourceGroup()
  params: {
    name: '${name}-devCenter'
    location: location
    settings: settings
  }
}

@description('Dev Center Identity')
module devCenterIdentity '../../identity/roleAssignmentsResource.bicep' = {
  name: 'devCenterIdentity'
  scope: resourceGroup()
  params: {
    principalId: devCenter.outputs.principalId
    roles: settings.identity.roles
    scope: 'subscription'
  }
}
