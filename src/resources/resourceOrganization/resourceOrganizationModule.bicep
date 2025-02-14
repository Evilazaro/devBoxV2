@description('Laning Zones')
param landingZones array

@description('Location for the deployment')
param location string = 'eastus2'

@description('Resource Goups creation')
module resourceGroup 'resourceGroupResource.bicep' = [
  for landingZone in landingZones: {
    name: '${landingZone.name}'
    scope: subscription()
    params: {
      name: landingZone.name
      location: location
    }
  }
]
