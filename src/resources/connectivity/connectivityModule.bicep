@description('Network settings for the connectivity module.')
param networkSettings object

module vnet 'virtualNetworkResource.bicep' = if (networkSettings.createVirtualNetwork) {
  name: networkSettings.name
  params: {
    name: networkSettings.name
    location: resourceGroup().location
    addressPrefixes: networkSettings.addressPrefixes
    subnets: networkSettings.subnets
    tags: networkSettings.tags
  }
}
