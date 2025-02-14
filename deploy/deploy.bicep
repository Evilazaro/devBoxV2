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

// var networkSettings = environment == 'dev'
//   ? loadJsonContent('../src/resources/connectivity/settings/dev/networkSettings.json')
//   : loadJsonContent('../src/resources/connectivity/settings/prod/networkSettings.json')

targetScope = 'subscription'
@description('Deploy the Connectivity Resources Group')
module connectivityResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'connectivityResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.connectivity.name
    location: location
    tags: landingZone.connectivity.tags
  }
}

@description('Deploy the Identity Resources Group')
module identityResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'identityResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.identity.name
    location: location
    tags: landingZone.identity.tags
  }
}

@description('Deploy the management Resources Group')
module managementResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'managementResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.management.name
    location: location
    tags: landingZone.management.tags
  }
}

@description('Deploy the workload Resources Group')
module workloadResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'workloadResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.workload.name
    location: location
    tags: landingZone.workload.tags
  }
}

@description('Deploy the Dev Center Workload')
module devCenter  '../src/resources/workload/devCenter/devCenterModule.bicep' = {
  scope: resourceGroup(landingZone.workload.name)
  name: 'devCenter'
  params: {
    name: 'devcenter'
    settings: settings
  }
  dependsOn: [
    workloadResourceGroup
  ]
}
