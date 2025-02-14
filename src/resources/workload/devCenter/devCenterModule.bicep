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
var devCenterSettings = environment == 'dev' ? loadJsonContent('settings/dev/devCenterSettings.json') : loadJsonContent('settings/prod/devCenterSettings.json')

@description('Dev Center Resource')
module devCenter './devCenterResource.bicep' = {
  name: '${name}-${uniqueString(name,resourceGroup().id)}-devCenter'	
  scope: resourceGroup()
  params: {
    name: name
    location: location
    devCenterSettings: devCenterSettings
  }
}
