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

var landingZones = environment == 'dev'
  ? loadJsonContent('../src/resources/resourceOrganization/settings/dev/resourceOrganizationSettings.json')
  : loadJsonContent('../src/resources/resourceOrganization/settings/prod/resourceOrganizationSettings.json')

@description('Dev Center settings')
var settings = environment == 'dev'
  ? loadJsonContent('../src/resources/workload/devCenter/settings/dev/settings.json')
  : loadJsonContent('../src/resources/workload/devCenter/settings/prod/settings.json')

var networkSettings = environment == 'dev'
  ? loadJsonContent('../src/resources/connectivity/settings/dev/networkSettings.json')
  : loadJsonContent('../src/resources/connectivity/settings/prod/networkSettings.json')

@description('Resource Goups creation')
module resourceGroup '../src/resources/resourceOrganization/resourceGroupResource.bicep' = [
  for landingZone in landingZones: {
    name: '${landingZone.name}-landingZone'
    scope: subscription()
    params: {
      name: landingZone.name
      location: location
    }
  }
]
