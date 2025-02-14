@description('The name of the virtual network resource.')
param name string

@description('The address space for the virtual network resource.')
param addressPrefixes array

@description('Subnets for the virtual network resource.')
param subnets array

@description('Virtual network tags')
param tags object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: resourceGroup().location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: subnets
  }
}

@description('The ID of the virtual network resource.')
output id string = virtualNetwork.id

@description('The name of the virtual network resource.')
output name string = virtualNetwork.name

@description('The Subnets of the virtual network resource.')
output subnets array = virtualNetwork.properties.subnets
