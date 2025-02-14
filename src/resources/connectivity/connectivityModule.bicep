@description('Network settings for the connectivity module.')
param networkSettings object

@description('Deploys a virtual network if createVirtualNetwork is true.')
module vnet 'virtualNetworkResource.bicep' = {
  name: 'virtualNetwork'
  params: {
    name: '${networkSettings.name}'
    addressPrefixes: networkSettings.addressPrefixes
    subnets: [
      for subnet in networkSettings.subnets: {
        name: '${subnet.name}'
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
    tags: networkSettings.tags
  }
}

@description('Deploys network connections for each subnet in the virtual network.')
module networkConnections 'networkConnectionResource.bicep' = [
  for subnet in networkSettings.subnets: {
    name: '${subnet.name}-networkConnection'
    params: {
      name: '${vnet.outputs.subnets[0].name}-networkConnection'
      subnetId: vnet.outputs.subnets[0].id
      tags: networkSettings.tags
    }
  }
]
