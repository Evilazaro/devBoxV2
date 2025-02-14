@description('Solution Name')
param solutionName string

@description('Location for the deployment')
param location string

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

// Load Configuration Files based on Environment

var landingZone = environment == 'dev'
  ? loadJsonContent('../src/resources/resourceOrganization/settings/dev/resourceOrganizationSettings.json')
  : loadJsonContent('../src/resources/resourceOrganization/settings/prod/resourceOrganizationSettings.json')

@description('Dev Center settings')
var settings = environment == 'dev'
  ? loadJsonContent('../src/resources/workload/devCenter/settings/dev/settings.json')
  : loadJsonContent('../src/resources/workload/devCenter/settings/prod/settings.json')

var networkSettings = environment == 'dev'
  ? loadJsonContent('../src/resources/connectivity/settings/dev/networkSettings.json')
  : loadJsonContent('../src/resources/connectivity/settings/prod/networkSettings.json')

targetScope = 'subscription'

resource connectivityResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${solutionName}-${landingZone.connectivity.name}-RG'
  location: location
  tags: landingZone.connectivity.tags
}

module connectivity '../src/resources/connectivity/connectivityModule.bicep'= {
  scope: connectivityResourceGroup
  name: 'connectivity'
  params: {
    networkSettings: networkSettings
  }
}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${solutionName}-${landingZone.workload.name}-RG'
  location: location
  tags: landingZone.workload.tags
}

module devCenter '../src/resources/workload/devCenter/devCenterModule.bicep'= {
  scope: resourceGroup
  name: 'workload'
  params: {
    name: 'EYDevCenter'
    settings: settings
    location: location
  }
}
