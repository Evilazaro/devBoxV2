targetScope = 'subscription'

@description('Workload Name')
param workloadName string

@description('Location for the deployment')
param location string

@description('Landing Zone Information')
param landingZone object 

@description('Deployment Environment')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Connectivity Resource Group')
resource connectivityResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.connectivity.name}-${environment}'
  location: location
  tags: landingZone.connectivity.tags
}

@description('Resource Group Name')
output connectivityResourceGroupName string = connectivityResourceGroup.name

@description('Resource Group Id')
output connectivityResourceGroupId string = connectivityResourceGroup.id

@description('Connectivity Resource Group')
resource managementResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.management.name}-${environment}'
  location: location
  tags: landingZone.management.tags
}

@description('Resource Group ID')
output managementResourceGroupId string = managementResourceGroup.id

@description('Resource Group Name')
output managementResourceGroupName string = managementResourceGroup.name

@description('Connectivity Resource Group')
resource workloadResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: '${workloadName}-${landingZone.workload.name}-${environment}'
  location: location
  tags: landingZone.workload.tags
}

@description('Resource Group ID')
output workloadResourceGroupId string = workloadResourceGroup.id

@description('Resource Group Name')
output workloadResourceGroupName string = workloadResourceGroup.name
