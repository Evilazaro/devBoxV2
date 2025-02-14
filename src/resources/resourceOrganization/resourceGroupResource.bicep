targetScope = 'subscription'

@description('The name of the resource group.')
param name string

@description('Location for the resource group.')
param location string 

@description('Resource group tags')
param tags object = {}

@description('Resource group resource')
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: tags
}
