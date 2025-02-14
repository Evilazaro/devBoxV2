@description('Network settings for the connectivity module.')
param networkSettings object

@description('Deploys a virtual network if createVirtualNetwork is true.')
module vnet 'virtualNetworkResource.bicep' = if (networkSettings.createVirtualNetwork == true) {
  name: networkSettings.name
  params: {
    name: networkSettings.name
    addressPrefixes: networkSettings.addressPrefixes
    subnets: [
      for subnet in networkSettings.subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
    tags: networkSettings.tags
  }
}
