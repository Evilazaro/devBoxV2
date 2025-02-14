@description('Network settings for the connectivity module.')
param networkSettings object

@description('Deploys a virtual network if createVirtualNetwork is true.')
module vnet 'virtualNetworkResource.bicep' = if (networkSettings.createVirtualNetwork == true) {
  name: 'virtualNetwork'
  params: {
    name: '${networkSettings.name}-VNet'
    addressPrefixes: networkSettings.addressPrefixes
    subnets: [
      for subnet in networkSettings.subnets: {
        name: '${subnet.name}-Subnet'
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
    tags: networkSettings.tags
  }
}
