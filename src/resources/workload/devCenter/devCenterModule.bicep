@description('The name of the Dev Center resource.')
param name string

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

var networkSettings = environment == 'dev'
  ? loadJsonContent('settings/dev/networkSettings.json')
  : loadJsonContent('settings/prod/networkSettings.json')

@description('Dev Center Resource')
module devCenter './devCenterResource.bicep' = {
  name: 'devCenter'
  scope: resourceGroup()
  params: {
    name: '${name}-${uniqueString(name,resourceGroup().id)}-devCenter'
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
