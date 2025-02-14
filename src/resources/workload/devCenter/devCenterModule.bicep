@description('The name of the Dev Center resource.')
param name string = 'module'

@description('Location for the Dev Center resource.')
param location string = resourceGroup().location

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

@description('Dev Center settings')
var settings = environment == 'dev'
  ? loadJsonContent('settings/dev/settings.json')
  : loadJsonContent('settings/prod/settings.json')

@description('Dev Center Resource')
module devCenter './devCenterResource.bicep' = {
  name: '${name}-${uniqueString(name,resourceGroup().id)}-devCenter'
  scope: resourceGroup()
  params: {
    name: name
    location: location
    settings: settings
  }
}

@description('Dev Center Identity')
module devCenterIdentity '../../identity/roleAssignmentsResource.bicep' = {
  name: 'Identity-${uniqueString(name,resourceGroup().id)}-devCenter'
  scope: resourceGroup()
  params: {
   principalId: devCenter.outputs.principalId
   roles: settings.identity.roles
   scope: 'subscription'
  }
}
