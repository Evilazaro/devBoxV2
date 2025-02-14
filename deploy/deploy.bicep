@description('Location for the deployment')
param location string = 'eastus2'

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

// Load Configuration Files based on Environment

var landingZone = environment == 'dev'
  ? loadJsonContent('../src/resources/resourceOrganization/settings/dev/resourceOrganizationSettings.json')
  : loadJsonContent('../src/resources/resourceOrganization/settings/prod/resourceOrganizationSettings.json')

// @description('Dev Center settings')
// var settings = environment == 'dev'
//   ? loadJsonContent('../src/resources/workload/devCenter/settings/dev/settings.json')
//   : loadJsonContent('../src/resources/workload/devCenter/settings/prod/settings.json')

// var networkSettings = environment == 'dev'
//   ? loadJsonContent('../src/resources/connectivity/settings/dev/networkSettings.json')
//   : loadJsonContent('../src/resources/connectivity/settings/prod/networkSettings.json')

@description('Deploy the Connectivity Resources Group')
module connectivityResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'connectivityResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.connectivity.name
    location: location
  }
}

@description('Deploy the Identity Resources Group')
module identityResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'identityResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.identity.name
    location: location
  }
}

@description('Deploy the management Resources Group')
module managementResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'managementResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.management.name
    location: location
  }
}

@description('Deploy the workload Resources Group')
module workloadResourceGroup  '../src/resources/resourceOrganization/resourceGroupResource.bicep'= {
  name: 'workloadResourceGroup'
  scope: subscription()
  params: {
    name: landingZone.workload.name
    location: location
  }
}
